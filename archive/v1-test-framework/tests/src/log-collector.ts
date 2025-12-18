import { spawn, ChildProcess, execSync } from "child_process";
import {
  createWriteStream,
  WriteStream,
  writeFileSync,
  readFileSync,
  existsSync,
  unlinkSync,
  readdirSync,
  fsyncSync,
} from "fs";
import path from "path";

interface TestMarkerState {
  startWritten: boolean;
  endWritten: boolean;
}

/**
 * LogCollector pipes `docker compose logs --follow` to a persistent file
 * with embedded text markers for precise test boundary extraction.
 *
 * Design improvements over in-memory version:
 * - Crash resilient: logs persist on disk at /tmp/ollama37-session-{timestamp}.log
 * - Bounded memory: no array growth, only file I/O
 * - Precise markers: text-based extraction with sed
 *
 * Marker format: ===MARKER:{TYPE}:{TEST_ID}:{ISO_TIMESTAMP}===
 * - TYPE: START, END, or SESSION
 * - TEST_ID: Test case identifier (e.g., TC-RUNTIME-001)
 * - ISO_TIMESTAMP: When the marker was written
 *
 * Log extraction uses sed to extract logs between START and END markers,
 * writing to /tmp/test-{testId}-logs.txt for test steps to access.
 */
export class LogCollector {
  private process: ChildProcess | null = null;
  private sessionFile: string;
  private logFileStream: WriteStream | null = null;
  private workingDir: string;
  private isRunning: boolean = false;
  private testMarkers: Map<string, TestMarkerState> = new Map();
  private writeQueue: Promise<void> = Promise.resolve();
  private lineBuffer: string = "";

  constructor(workingDir: string) {
    // workingDir should be the project root, docker-compose.yml is in docker/
    this.workingDir = path.join(workingDir, "docker");
    // Generate unique session file with timestamp
    this.sessionFile = `/tmp/ollama37-session-${Date.now()}.log`;
  }

  /**
   * Start the log collector background process.
   * Creates session file and spawns docker compose logs --follow.
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      return;
    }

    // Clean up old session files (> 24 hours)
    this.cleanupOldSessions();

    return new Promise((resolve, reject) => {
      // Create file stream first (synchronously to guarantee it exists)
      this.logFileStream = createWriteStream(this.sessionFile, { flags: "a" });

      // Write session header
      this.logFileStream.write(
        `===SESSION:START:${new Date().toISOString()}===\n`
      );

      // Spawn docker compose logs --follow
      this.process = spawn(
        "docker",
        ["compose", "logs", "--follow", "--timestamps"],
        {
          cwd: this.workingDir,
          stdio: ["ignore", "pipe", "pipe"],
        }
      );

      this.isRunning = true;

      // Pipe stdout to file with line buffering
      this.process.stdout?.on("data", (data: Buffer) => {
        this.processLogData(data, false);
      });

      // Pipe stderr (docker compose messages) to file with prefix
      this.process.stderr?.on("data", (data: Buffer) => {
        this.processLogData(data, true);
      });

      this.process.on("error", (err) => {
        this.isRunning = false;
        reject(err);
      });

      this.process.on("close", () => {
        this.isRunning = false;
      });

      // Give docker compose time to start
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
   * Stop the log collector background process.
   * Writes session end marker and closes file stream.
   */
  async stop(): Promise<void> {
    if (!this.process || !this.isRunning) {
      return;
    }

    // Flush any remaining buffered data
    if (this.lineBuffer) {
      this.queueWrite(this.lineBuffer + "\n");
      this.lineBuffer = "";
    }

    return new Promise((resolve) => {
      let resolved = false;
      const doResolve = () => {
        if (!resolved) {
          resolved = true;
          this.isRunning = false;

          // Write session end marker and close stream
          if (this.logFileStream && !this.logFileStream.destroyed) {
            this.logFileStream.write(
              `===SESSION:END:${new Date().toISOString()}===\n`
            );
            this.logFileStream.end();
          }

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
   * Mark the start of a test - writes START marker to session file.
   */
  markTestStart(testId: string): void {
    // Clean up any stale test log file from previous runs
    const testLogPath = `/tmp/test-${testId}-logs.txt`;
    if (existsSync(testLogPath)) {
      try {
        unlinkSync(testLogPath);
      } catch {
        // Ignore cleanup errors
      }
    }

    const timestamp = new Date().toISOString();
    this.testMarkers.set(testId, { startWritten: true, endWritten: false });
    this.queueWrite(`===MARKER:START:${testId}:${timestamp}===\n`);
  }

  /**
   * Mark the end of a test - writes END marker to session file.
   */
  markTestEnd(testId: string): void {
    const timestamp = new Date().toISOString();
    const state = this.testMarkers.get(testId);
    if (state) {
      state.endWritten = true;
    }
    this.queueWrite(`===MARKER:END:${testId}:${timestamp}===\n`);
  }

  /**
   * Write current test logs to file (call during test execution).
   * Extracts logs between START and END markers using sed.
   * This allows test steps to access logs accumulated so far.
   */
  writeCurrentLogs(testId: string): void {
    const outputPath = `/tmp/test-${testId}-logs.txt`;

    // Ensure pending writes are flushed to disk
    this.syncFlush();

    const markerState = this.testMarkers.get(testId);
    if (!markerState?.startWritten) {
      // No start marker yet, write empty file
      writeFileSync(outputPath, "");
      return;
    }

    try {
      // Escape testId for use in sed pattern (handle special regex chars)
      const escapedTestId = this.escapeRegex(testId);
      let sedCmd: string;

      if (markerState.endWritten) {
        // Extract between START and END markers (excluding marker lines)
        sedCmd = `sed -n '/===MARKER:START:${escapedTestId}:/,/===MARKER:END:${escapedTestId}:/{/===MARKER:/d;p}' "${this.sessionFile}"`;
      } else {
        // Extract from START to EOF (test still running, no END marker yet)
        // Note: Use ${'$'} to insert literal $ in template literal (avoids ${} interpolation)
        sedCmd = `sed -n '/===MARKER:START:${escapedTestId}:/,${'$'}{/===MARKER:/d;p}' "${this.sessionFile}"`;
      }

      const result = execSync(sedCmd, {
        encoding: "utf-8",
        maxBuffer: 10 * 1024 * 1024,
      });
      writeFileSync(outputPath, result);
    } catch {
      // If extraction fails, write empty file (test steps have fallback)
      writeFileSync(outputPath, "");
    }
  }

  /**
   * Get logs for a specific test (between start and end markers).
   */
  getLogsForTest(testId: string): string {
    this.writeCurrentLogs(testId);
    const outputPath = `/tmp/test-${testId}-logs.txt`;
    try {
      return readFileSync(outputPath, "utf-8");
    } catch {
      return "";
    }
  }

  /**
   * Get all logs collected so far (entire session file).
   */
  getAllLogs(): string {
    this.syncFlush();
    try {
      return readFileSync(this.sessionFile, "utf-8");
    } catch {
      return "";
    }
  }

  /**
   * Check if the collector is running.
   */
  isActive(): boolean {
    return this.isRunning;
  }

  /**
   * Get the session file path (useful for debugging).
   */
  getSessionFilePath(): string {
    return this.sessionFile;
  }

  // ============================================
  // Deprecated methods for backwards compatibility
  // ============================================

  /**
   * @deprecated No longer meaningful with file-based approach.
   * Returns all logs instead.
   */
  getLogsSince(_startIndex: number): string {
    return this.getAllLogs();
  }

  /**
   * @deprecated No longer meaningful with file-based approach.
   * Returns 0.
   */
  getLogCount(): number {
    return 0;
  }

  // ============================================
  // Private methods
  // ============================================

  /**
   * Process incoming log data with line buffering.
   * Ensures complete lines are written and markers don't split lines.
   */
  private processLogData(data: Buffer, isStderr: boolean): void {
    const text = this.lineBuffer + data.toString();
    const lines = text.split("\n");

    // Keep incomplete last line in buffer
    this.lineBuffer = lines.pop() || "";

    // Write complete lines
    if (lines.length > 0) {
      const prefix = isStderr ? "[stderr] " : "";
      const formatted = lines.map((l) => prefix + l).join("\n") + "\n";
      this.queueWrite(formatted);
    }
  }

  /**
   * Queue a write to the log file.
   * All writes go through this queue to prevent race conditions
   * between log data and markers.
   */
  private queueWrite(data: string): void {
    this.writeQueue = this.writeQueue.then(() => {
      return new Promise<void>((resolve) => {
        if (this.logFileStream && !this.logFileStream.destroyed) {
          this.logFileStream.write(data, () => resolve());
        } else {
          resolve();
        }
      });
    });
  }

  /**
   * Synchronously flush pending writes to disk.
   * Uses fsync to ensure kernel buffers are written.
   */
  private syncFlush(): void {
    if (this.logFileStream && !this.logFileStream.destroyed) {
      // Access the underlying file descriptor
      const fd = (this.logFileStream as any).fd;
      if (typeof fd === "number") {
        try {
          fsyncSync(fd);
        } catch {
          // Ignore fsync errors (fd might be invalid)
        }
      }
    }
  }

  /**
   * Escape special regex characters in test ID for sed patterns.
   */
  private escapeRegex(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  /**
   * Clean up old session files (older than 24 hours).
   */
  private cleanupOldSessions(): void {
    const oneDay = 24 * 60 * 60 * 1000;
    const now = Date.now();

    try {
      const files = readdirSync("/tmp").filter((f) =>
        f.startsWith("ollama37-session-")
      );
      for (const file of files) {
        const match = file.match(/ollama37-session-(\d+)\.log/);
        if (match) {
          const timestamp = parseInt(match[1]);
          if (now - timestamp > oneDay) {
            try {
              unlinkSync(`/tmp/${file}`);
            } catch {
              // Ignore individual file cleanup errors
            }
          }
        }
      }
    } catch {
      // Ignore cleanup errors
    }
  }
}
