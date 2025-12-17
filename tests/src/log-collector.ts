import { spawn, ChildProcess } from "child_process";
import { writeFileSync } from "fs";
import path from "path";

interface LogEntry {
  timestamp: Date;
  line: string;
}

interface TestMarker {
  start: number;
  end?: number;
}

/**
 * LogCollector runs `docker compose logs --follow` as a background process
 * and captures logs with precise test boundaries.
 *
 * This solves the log overlap problem where `docker compose logs --since=5m`
 * could include logs from previous tests or miss logs if a test exceeds 5 minutes.
 */
export class LogCollector {
  private process: ChildProcess | null = null;
  private logs: LogEntry[] = [];
  private testMarkers: Map<string, TestMarker> = new Map();
  private workingDir: string;
  private isRunning: boolean = false;

  constructor(workingDir: string) {
    // workingDir should be the project root, docker-compose.yml is in docker/
    this.workingDir = path.join(workingDir, "docker");
  }

  /**
   * Start the log collector background process
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      return;
    }

    return new Promise((resolve, reject) => {
      // Spawn docker compose logs --follow
      this.process = spawn("docker", ["compose", "logs", "--follow", "--timestamps"], {
        cwd: this.workingDir,
        stdio: ["ignore", "pipe", "pipe"],
      });

      this.isRunning = true;

      // Handle stdout (main log output)
      this.process.stdout?.on("data", (data: Buffer) => {
        const lines = data.toString().split("\n").filter((l) => l.trim());
        for (const line of lines) {
          this.logs.push({
            timestamp: new Date(),
            line: line,
          });
        }
      });

      // Handle stderr (docker compose messages)
      this.process.stderr?.on("data", (data: Buffer) => {
        const lines = data.toString().split("\n").filter((l) => l.trim());
        for (const line of lines) {
          this.logs.push({
            timestamp: new Date(),
            line: `[stderr] ${line}`,
          });
        }
      });

      this.process.on("error", (err) => {
        this.isRunning = false;
        reject(err);
      });

      this.process.on("close", (code) => {
        this.isRunning = false;
      });

      // Give it a moment to start
      setTimeout(() => {
        if (this.isRunning) {
          resolve();
        } else {
          reject(new Error("Log collector failed to start"));
        }
      }, 500);
    });
  }

  /**
   * Stop the log collector background process
   */
  async stop(): Promise<void> {
    if (!this.process || !this.isRunning) {
      return;
    }

    return new Promise((resolve) => {
      let resolved = false;
      const doResolve = () => {
        if (!resolved) {
          resolved = true;
          this.isRunning = false;
          resolve();
        }
      };

      this.process!.on("close", doResolve);

      this.process!.kill("SIGTERM");

      // Force kill after 5 seconds
      setTimeout(() => {
        if (this.isRunning && this.process) {
          this.process.kill("SIGKILL");
        }
        doResolve();
      }, 5000);
    });
  }

  /**
   * Mark the start of a test - records current log index
   */
  markTestStart(testId: string): void {
    this.testMarkers.set(testId, {
      start: this.logs.length,
    });
  }

  /**
   * Mark the end of a test - records current log index and writes logs to file
   */
  markTestEnd(testId: string): void {
    const marker = this.testMarkers.get(testId);
    if (marker) {
      marker.end = this.logs.length;

      // Write logs to temp file for test steps to access
      const logs = this.getLogsForTest(testId);
      const filePath = `/tmp/test-${testId}-logs.txt`;
      writeFileSync(filePath, logs);
    }
  }

  /**
   * Get logs for a specific test (between start and end markers)
   */
  getLogsForTest(testId: string): string {
    const marker = this.testMarkers.get(testId);
    if (!marker) {
      return "";
    }

    const endIndex = marker.end ?? this.logs.length;
    const testLogs = this.logs.slice(marker.start, endIndex);

    return testLogs.map((entry) => entry.line).join("\n");
  }

  /**
   * Get all logs collected so far
   */
  getAllLogs(): string {
    return this.logs.map((entry) => entry.line).join("\n");
  }

  /**
   * Get logs since a specific index
   */
  getLogsSince(startIndex: number): string {
    return this.logs.slice(startIndex).map((entry) => entry.line).join("\n");
  }

  /**
   * Get current log count (useful for tracking)
   */
  getLogCount(): number {
    return this.logs.length;
  }

  /**
   * Check if the collector is running
   */
  isActive(): boolean {
    return this.isRunning;
  }

  /**
   * Write current test logs to file (call during test execution)
   * This allows test steps to access logs accumulated so far
   */
  writeCurrentLogs(testId: string): void {
    const marker = this.testMarkers.get(testId);
    if (!marker) {
      return;
    }

    const testLogs = this.logs.slice(marker.start);
    const filePath = `/tmp/test-${testId}-logs.txt`;
    writeFileSync(filePath, testLogs.map((entry) => entry.line).join("\n"));
  }
}
