pip3 install bitsandbytes nf4
pip3 install transformers
pip3 install sage_attention
pip3 install sage-attention
pip3 install flash_attention
pip3 install flash_attention2
pip3 install flash_attention_2
pip3 install xformers
pip3 install tensors
pip3 install ggml
sudo zypper install python3.13-t
sudo zypper install python313-devel
sudo zypper install python313-toolkit
sudo zypper install python313-torch
sudo zypper install python313-pillow
sudo zypper install python313-xformers
sudo zypper install python313-accelerate
sudo zypper dup
sudo zypper install /home/sera/Downloads/python313-scikit-learn-1.7.2-90.178.x86_64.rpm
sudo zypper install /home/sera/Downloads/python311-scikit-learn-1.7.2-90.178.x86_64.rpm
sudo zypper dup
sudo zypper inr
sudo zypper install pipewire
sudo zypper dup
sudo zypper update
sudo zypper update -f\
sudo zypper update -f
sudo zypper patch
sudo zypper install sof-firmware
systemctl --user unmask pipewire-pulse.service
systemctl --user enable pipewire-pulse --now
sudo udevadm trigger
systemctl --user restart pipewire wireplumber pipewire-pulse
systemctl --user status pipewire.socket pipewire-pulse.socket wireplumber.service
systemctl --user enable wireplumber pipewire pipewire-pulse --now
sudo rm -r /etc/xdg/systemd/user/pipewire-pulse.service → /dev/null
mv ~/.config/wireplumber ~/.config/wireplumber.old
mv ~/.local/share/wireplumber ~/.local/share/wireplumber.old
mv ~/.config/pipewire ~/.config/pipewire.old
sudo rm -r ~/.config/wireplumber
sudo snapper rollback
sudo reboot
cd ~/hf-models
git clone https://huggingface.co/ibm-granite/granite-4.1-8b Granite-4.1-8B
cd .glassmorphism_app
cd app
cd .env
cd bin
source activate
pip3 install ggml
pip3 install tensors
pip3 install xformers
pip3 install pillow
pip3 install bitsandbytes
sudo zypper install python313-devel
sudo zypper install python313-accelerate
pip3 install flash_attention_2
pip3 install flash_attention
pip3 install flash_attention_2
pip install --upgrade pip
pip3 install transformers
/home/sera/.glassmorphism_app/Run_Program.sh 
export CUDA_VISIBLE_DEVICES=2,4
/home/sera/.glassmorphism_app/Run_Program.sh 
pip3 uninstall bitsandbytes -y
git clone https://github.com/bitsandbytes-foundation/bitsandbytes.git
cd bitsandbytes
cmake -DCOMPUTE_BACKEND=cuda -S .
export PATH=$PATH:/usr/local/cuda/bin.
cmake -DCOMPUTE_BACKEND=cuda -S .
sudo zypper install cuda-toolkit-128
sudo zypper install cuda-toolkit-12_8
sudo zypper install cuda-toolkit-12-8
export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}
cmake -DCOMPUTE_BACKEND=cuda -S .
cmake -Wno-deprecated-gpu-targets -DCOMPUTE_BACKEND=cuda -S .
cmake -Wno-deprecated-gpu-targets -allow-unsupported-compiler -DCOMPUTE_BACKEND=cuda -S .
cmake -Wno-deprecated-gpu-targets -DCOMPUTE_BACKEND=cuda -allow-unsupported-compiler -S .
cd ~
/home/sera/.glassmorphism_app/Run_Program.sh
ip addr
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
\
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,3,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
pip install bitsandbytes==0.41.1 
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/.lilymorphism/Run_Program.sh 
/home/sera/Builds/Sybilmorphism/Run_Program.sh 
export CUDA_VISIBLE_DEVICES=2,4
export CUDA_VISIBLE_DEVICES=2
/home/sera/Builds/Lilymorphism/Run_Program.sh 
export CUDA_VISIBLE_DEVICES=2,4
/home/sera/Builds/Lilymorphism/Run_Program.sh 
ollama pull openbmb/minicpm-o4.5:q5_K_M
ollama pull hf.co/mradermacher/granite-4.1-8b-i1-GGUF:IQ3_M
/home/sera/Builds/Lilymorphism/Run_Program.sh 
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,3,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,3,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo docker ls
sudo zypper dup
sudo snapper list
sudo snapper rollback
sudo reboot
sudo zypper uninstall NVIDIA
sudo zypper remove NVIDIA
sudo zypper remove nvidia
sudo zypper remove --clean-deps '*nvidia*' '*cuda*'
sudo snapper list
sudo snapper rollback 836
sudo reboot
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh 
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo zypper install ocl-icd-devel-2.3.4-lp160.65.3.x86_64.rmp nvidia-xconfig-595.71.05-lp160.2.1.x86_64.rmp
cd /home/sera/Downloads/New NVIDIA (May 1st 2026)/595.71/
cd "/home/sera/Downloads/New NVIDIA (May 1st 2026)/595.71/"
sudo zypper install *.rpm
sudo zypper inr
sudo zypper ref -f
sudo zypper inr
sudo zypper search -i | grep nvidia
sudo zypper in nvidia-open-driver-G07-signed-kmp-meta
sudo zypper install nvidia-open-driver-G07-signed-kmp-meta
sudo zypper install /home/sera/Downloads/New NVIDIA (May 1st 2026)/595.71/nvidia-open-driver-G07-signed-kmp-meta-595.58.03-lp160.15.1.x86_64.rpm
sudo zypper install "/home/sera/Downloads/New NVIDIA (May 1st 2026)/595.71/nvidia-open-driver-G07-signed-kmp-meta-595.58.03-lp160.15.1.x86_64.rpm"
sudo zypper in nvidia-driver-G07-signed-kmp-default
sudo zypper in nvidia-open-driver-G07-signed-kmp-meta nvidia-userspace-meta-G07 nvidia-compute-utils-G07
sudo zypper install /home/sera/Downloads/nvidia-open-driver-G07-signed-595.71.05-lp160.3.1.src.rpm 
sudo zypper search -i | grep nvidia
sudo zypper remove libnvidia-gpucomp-G06-32bit
sudo zypper remove 
sudo zypper remove libnvidia-gpucomp-G06
sudo reboot
sudo snapper list
sudo snapper rollback 841
sudo reboot
sudo rollback
sudo snapper rollback
sudo reboot
/home/sera/Builds/Lilymorphism/Run_Program.sh 
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo zypper inr
sudo zypper dup
sudo zypper search -i | grep nvidia
sudo snapper list
sudo snapper rollback 856
sudo reboot
sudo snapper list
sudo snapper rollback
sudo reboot
source ~/llama.cpp_3/.env/bin/activate
hf upload --commit-message "Added Q8_0 mmproj" EnlistedGhost/Ministral-3-3B-Reasoning-2512-GGUF /home/sera/LLM-Quants/Ministral-3-3B-Quants
hf upload --commit-message "Added expiremental QX4_K file" EnlistedGhost/Ministral-3-3B-Reasoning-2512-GGUF /home/sera/LLM-Quants/Ministral-3-3B-Quants
hf upload --commit-message "Added expiremental Q3_K_XL file" EnlistedGhost/Ministral-3-3B-Reasoning-2512-GGUF /home/sera/LLM-Quants/Ministral-3-3B-Quants
source ~/llama.cpp_3/.env/bin/activate
python /home/sera/llama.cpp/convert_hf_to_gguf.py /run/media/sera/GH44-Ancillary/AURORA-R11-GH44/home/sera/hf-models/Ministral-3-3B-Reasoning-2512 --outtype q8_0 --mmproj --outfile ~/LLM-Quants/mmproj-Ministral-3-3B-Reasoning-2512-Q8_0.gguf
python /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/GH44-Ancillary/AURORA-R11-GH44/home/sera/hf-models/Ministral-3-3B-Reasoning-2512 --outtype q8_0 --mmproj --outfile ~/LLM-Quants/mmproj-Ministral-3-3B-Reasoning-2512-Q8_0.gguf
python /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/GH44-Ancillary/AURORA-R11-GH44/home/sera/hf-models/Ministral-3-3B-Reasoning-2512 --outtype f16 --outfile /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-F16.gguf
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_q=q4_k --tensor-type attn_k =q5_k --tensor-type attn_v=q5_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --tensor-type attn_output=q4_k --output-tensor-type q6_k --token-embedding-type q5_k /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-F16.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-QX4_K.gguf Q4_K_M 6
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_q=q4_k --tensor-type attn_k=q5_k --tensor-type attn_v=q5_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --tensor-type attn_output=q4_k --output-tensor-type q6_k --token-embedding-type q5_k /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-F16.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-QX4_K.gguf Q4_K_M 6
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_q=q3_k --tensor-type attn_k=q5_k --tensor-type attn_v=q5_k --tensor-type ffn_gate=q4_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --tensor-type attn_output=q4_k --output-tensor-type q6_k --token-embedding-type q5_k /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-F16.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Ministral-3-3B-Reasoning-2512-QX4_K.gguf Q4_K_M 6
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ssh root@
ssh root@96.126.114.115
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh 
ollama pull hf.co/Jackrong/Qwen3.5-9B-DeepSeek-V4-Flash-GGUF:Q5_K_M
ollama pull hf.co/bartowski/mistralai_Mistral-Medium-3.5-128B-GGUF:IQ2_M
ollama pull hf.co/bartowski/mistralai_Mistral-Small-4-119B-2603-GGUF:Q2_K_L
ollama list
ollama create Mistral-4-119B:Q2_L -f /home/sera/LLM-Quants/hf-Mistral_Small_4_119B.md
ollama rm hf.co/bartowski/mistralai_Mistral-Small-4-119B-2603-GGUF:Q2_K_L
ollama create Mistral-Medium-3.5:IQ2_M -f /home/sera/LLM-Quants/hf-Mistral_Medium_3.5_128B.md
ollama rm hf.co/bartowski/mistralai_Mistral-Medium-3.5-128B-GGUF:IQ2_M
ollama create Granite-4.1-8B:IQ3_M -f /home/sera/LLM-Quants/hf-Granite_4.1-8B.md
ollama rm hf.co/mradermacher/granite-4.1-8b-i1-GGUF:IQ3_M
ollama list
ollama create DeepSeek-V4-9B:Q5_K -f /home/sera/LLM-Quants/hf-Qwen35-DeepSeekV4-Flash.md
ollama create DeepSeek-V4-9B:Q5_K -f "/home/sera/LLM-Quants/hf-Qwen35-DeepSeekV4-Flash.md"
ollama list
ollama rm hf.co/Jackrong/Qwen3.5-9B-DeepSeek-V4-Flash-GGUF:Q5_K_M
ollama create MiniCPM-4o:Q5_K_M -f /home/sera/LLM-Quants/hf-Qwen35-DeepSeekV4-Flash.md
ollama rm openbmb/minicpm-o4.5:Q5_K_M
ollama list
/home/sera/.glassmorphism_app/Run_Program.sh 
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo reboot
/home/sera/Builds/Lilymorphism/Run_Program.sh 
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/Builds/Lilymorphism/Run_Program.sh 
source ~/llama.cpp_3/.env/bin/activate
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
source ~/llama.cpp_3/.env/bin/activate
ollama --version
ollama list
ollama run Mistral-4-119B:Q2_L
ls -la
cd .github-repo
git clone https://github.com/EnlistedGhost/ollama
ollama pull hf.co/bartowski/Qwen_Qwen3.5-9B-GGUF:Q6_K_L
ollama --version
ollama pull hf.co/bartowski/Qwen_Qwen3.5-9B-GGUF:Q6_K_L
ollama pull hf.co/bartowski/Qwen_Qwen3.5-9B-GGUF:Q5_K_M
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ollama --version
ollama pull hf.co/bartowski/Qwen_Qwen3.5-4B-GGUF:IQ3_M
ollama rm hf.co/bartowski/Qwen_Qwen3.5-4B-GGUF:IQ3_M
ollama list
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serveOLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=1 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=384 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo zypper ref -f
ollama create Mistral-Small-4-119B-Vert:Q2_K_L -f /home/sera/LLM-Quants/Mistral-4-119B:Q2_L
ollama list
ollama show Mistral-Small-4-119B-2603:Q2_K_L --modelfile
ollama list
ollama show Mistral-Medium-3.5-128B:IQ2_S --modelfile
sudo zypper install cmake go-golang
sudo zypper install cmake go1.22 gcc-c++ git
source ~/llama.cpp_3/.env/bin/activate
python3 /home/sera/Python-Scripts/Ollama-Model-Dumper-To-GGUF.py 
ollama create Mistral-Small-4-119B:Q2_K_L -f /home/sera/LLM-Quants/Mistral-4-119B:Q2_L
ollama list
ollama pull hf.co/bartowski/mistralai_Mistral-Medium-3.5-128B-GGUF:IQ2_S
ollama run hf.co/bartowski/mistralai_Mistral-Medium-3.5-128B-GGUF:IQ2_S
ollama create Mistral-Medium-3.5-128B:IQ2_S -f /home/sera/LLM-Quants/Mistral-4-119B:Q2_L
ollama run Mistral-Medium-3.5-128B:IQ2_S
ollama --version
nvcc --version
export PATH=$PATH:/usr/local/cuda/bin
nvcc --version
export GOMAXPROCS=6
cd /home/sera/Builds/ollama-src-0_21_3_rc0-linux-amd64
go generate ./...
wget https://go.dev
mkdir go-new
tar -C go-new -xzf go1.24.1.linux-amd64.tar.gz
tar -C go-new -xzf go1.24.13.linux-amd64.tar.gz
export PATH=go-new/go/bin:$PATH
export PATH=~/Builds/ollama-src-0_21_3_rc0-linux-amd64/go-new/go/bin:$PATH
go version
go generate ./...
export GOMAXPROCS=4
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
export MAKEFLAGS="-j4"
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go generate ./...
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go clean -cache
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
sudo chmod -R 777 /home/sera/Builds/ollama-src-0_21_3_rc0-linux-amd64/*
cd /home/sera/Builds/ollama-src-0_21_3_rc0-linux-amd64
export PATH=$PATH:/usr/local/cuda/bin
export PATH=~/Builds/ollama-src-0_21_3_rc0-linux-amd64/go-new/go/bin:$PATH
go clean -cache
go generate ./...
go clean -cache
go generate ./...
tar -C go-new -xzf go1.24.13.linux-amd64.tar.gz
go clean -cache
go generate ./...
export MAKEFLAGS="-j4"
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go clean -cache
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go clean -cache
go build -Waggressive-loop-optimizations -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go clean -cache
go generate ./...
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 -Waggressive-loop-optimizations .
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 -Waggressive-loop-optimizations=0 .
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 -aggressive-loop-optimizations=0 .
export MAKEFLAGS="-j4, -fno-aggressive-loop-optimizations"
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
cd llama
make -f Makefile.sync apply-patches
make -f Makefile.sync apply-patches -j 2
make -f Makefile.sync apply-patches -j2
cd ../
make -f Makefile.sync apply-patches -j2
export MAKEFLAGS="-j4"
make -f Makefile.sync apply-patches -j2
cd llama
make -f ../Makefile.sync apply-patches
make clean -f ../Makefile.sync apply-patches
git am --continue
cd llama/vendorgit am --continue
cd llama/vendor
git am --continue
make -f Makefile.sync apply-patches
make -f ../../../Makefile.sync apply-patches
make clean -f ../../../Makefile.sync apply-patches
cd ../../../
make clean -f Makefile.sync apply-patches
git -C llama/vendor am --continue
make -f Makefile.sync format-patches
make -f Makefile.sync clean apply-patches
git am --show-current-patch=diff
cd llama
cd vendor
git am --show-current-patch=diff
ollama pull ollama run hf.co/AtomicChat/gemma-4-E4B-it-assistant-GGUF:F16
ollama pull hf.co/AtomicChat/gemma-4-E4B-it-assistant-GGUF:F16
ollama pull hf.co/DevQuasar/nvidia.Nemotron-Elastic-12B-GGUF:Q5_K_M
ollama pull hf.co/ggml-org/Nemotron-3-Nano-4B-GGUF:Q8_0
ollama pull hf.co/ggml-org/gemma-4-E4B-it-GGUF:Q8_0
ollama pull hf.co/mradermacher/music-flamingo-hf-GGUF:Q5_K_M
ollama rm hf.co/ggml-org/Nemotron-3-Nano-4B-GGUF:Q8_0
/home/sera/Python-Scripts/Ollama-Model-Dumper-To-GGUF.py ollama list
ollama list
python3 /home/sera/Python-Scripts/Ollama-Model-Dumper-To-GGUF.py 
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row
export 
export CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row
cd /home/sera/Builds/ollama-src-0_21_3_rc0-linux-amd64
export MAKEFLAGS="-j4 -fno-aggressive-loop-optimizations"
export GOMAXPROCS=4
export PATH=$PATH:/usr/local/cuda/bin
export PATH=~/Builds/ollama-src-0_21_3_rc0-linux-amd64/go-new/go/bin:$PATH
go clean -cache
go generate ./...
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
git submodule update --init --recursive
go clean -cache
go generate ./...
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
cd /home/sera/Builds/ollama-src-0_21_3_rc0-linux-amd64
go generate ./...
go build -o ollama-cjz_0_21_3_rc0-linux-amd64 .
go mod vendor
go env GOMODCACHE
~/Builds/ollama-src-0_21_3_rc0-linux-amd64/go-new/go/bin/go mod vendor
mv ~/Builds/ollama-src-0_21_3_rc0-linux-amd64/go-new ~/go-new-toolchain
export PATH=$HOME/Builds/go-new-toolchain/go/bin:$PATH
go mod vendor
cd ~
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=2 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphism_app/Run_Program.sh
ollama run Mistral-Medium-3.5-128B:IQ2_S
ollama list
ollama run Mistral-Small-4-119B-2603:Q2_K_L
ollama run Mistral-Medium-3.5-128B:IQ2_S
/home/sera/Builds/Lilymorphism/Run_Program.sh 
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row \
export CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 11000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row \
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 9000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row \
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=2 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
export GGML_VK_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
llama-server -m /home/sera/LLM-Quants/Mistral-Small-4-119B-2603-Q2_K_L.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 9000     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row \
ollama pull hf.co/EnlistedGhost/Mag-Mell-Reasoner-12B-GGUF:Q5_K_XL
ollama pull hf.co/EnlistedGhost/Ministral-3-14B-Reasoning-2512-GGUF:Q4_K_XL
ollama pull hf.co/EnlistedGhost/Ministral-3-8B-Instruct-2512-GGUF:Q5_K_XL
ollama pull hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q4_K_XL
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ollama list
ollama run Mistral-Medium-3.5-128B:IQ2_M
ollama run Mistral-Small-4-119B-2603:Q2_K_L
ollama pull hf.co/bartowski/Llama-3.3-70B-Instruct-GGUF:IQ3_M
ollama run hf.co/bartowski/Llama-3.3-70B-Instruct-GGUF:IQ3_M
llama list
ollama list
ollama rm hf.co/EnlistedGhost/Ministral-3-8B-Instruct-2512-GGUF:Q5_K_XL
ollama rm hf.co/ggml-org/gemma-4-E4B-it-GGUF:Q8_0
ollama rm hf.co/AtomicChat/gemma-4-E4B-it-assistant-GGUF:F16
ollama list
ollama rm hf.co/bartowski/mistralai_Mistral-Medium-3.5-128B-GGUF:IQ2_S
ollama rm MiniCPM-4o:Q5_K_M
ollama rm Anubis-11B-Vision:Q4_MV2
ollama rm Anubis-11B-Vision:Q4_MeM
ollama rm Ministral-3-8B:IQ4_XS
ollama rm Magistral-Small-2506-24B:Q4_K_L
ollama rm Llama-3.3-8B:Onyx
ollama rm Mag-Mell-R1-12B:Magma
ollama rm Ministral-8B:Q6_KLX
ollama rm Llama-3SOME:Q5_K_M
ollama list
ollama rm hf.co/DevQuasar/nvidia.Nemotron-Elastic-12B-GGUF:Q5_K_M
ollama rm hf.co/bartowski/Llama-3.3-70B-Instruct-GGUF:IQ3_M
ollama list
/home/sera/Builds/Lilymorphism/Run_Program.sh 
source ~/llama.cpp_3/.env/bin/activate
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/AURORA-R11-GH44/home/sera/hf-models/Magistral-Small-2509/bin --outtype f16 --outfile /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type attn_output=q8_0 --tensor-type ffn_down=q8_0 --tensor-type ffn_up=q8_0 --tensor-type ffn_gate=f16 --output-tensor-type f16 --token-embedding-type f16 /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf Q8_0 8
source ~/llama.cpp_3/.env/bin/activate
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_q=q6_k --tensor-type attn_k=f16 --tensor-type attn_v=f16 --tensor-type attn_output=q8_0 --tensor-type ffn_down=q8_0 --tensor-type ffn_up=q8_0 --tensor-type ffn_gate=q8_0 --output-tensor-type q8_0 --token-embedding-type f16 /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_X.gguf Q8_0 8
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_q=q6_k --tensor-type attn_k=f16 --tensor-type attn_v=f16 --tensor-type attn_output=q8_0 --tensor-type ffn_down=q8_0 --tensor-type ffn_up=q8_0 --tensor-type ffn_gate=f16 --output-tensor-type q8_0 --token-embedding-type q8_0 /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf Q8_0 8
llama-quantize --tensor-type attn_norm=f16 --tensor-type attn_q=q6_k --tensor-type attn_k=f16 --tensor-type attn_v=f16 --tensor-type attn_output=f16 --tensor-type ffn_down=q6_k --tensor-type ffn_up=q6_k --tensor-type ffn_gate=f16 --output-tensor-type f16 --token-embedding-type f16 /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf Q8_0 8
export CUDA_VISIBLE_DEVICES=4,9
source /home/sera/comfy/ComfyUI/venv/.env/bin/activate
python3 /run/media/sera/AUX_AI512/comfy/ComfyUI/main.py
export CUDA_VISIBLE_DEVICES=4,8
python3 /run/media/sera/AUX_AI512/comfy/ComfyUI/main.py
export CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
python3 /run/media/sera/AUX_AI512/comfy/ComfyUI/main.py
source /comfy/ComfuUI/venv/.env/bin/activate
source /comfy/ComfuUI/.env/bin/activate
source /comfy/ComfuUI/venv/.venv/bin/activate
source /comfy/ComfuUI/.venv/bin/activate
ls -la source/comfy/ComfuUI/
ls -la /comfy/ComfuUI/
ls -la comfy/ComfuUI/
ls -la ~/comfy/ComfuUI/
ls -la /ComfuUI/.venv/bin/activate
bash: /comfy/ComfuUI/.venv/bin/activate
ls -la ~/ComfuUI/.venv/bin/activate
ls -la ~/comfy
ls -la ~/comfy/ComfyUI
ls -la ~/comfy/ComfyUI/venv
ls -la ~/comfy/ComfyUI/venv/.env
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py 
ollama list
ollama rm Mistral-Medium-3.5-128B:IQ2_S
ollama rm Mistral-Small-4-119B-2603:Q2_K_L
ollama rm Mistral-Medium-3.5-128B:IQ2_M
ollama rm Qwen3.5-9B:Opal
ollama rm Anubis-R1:Q4_K_M
ollama rm Deepseek-R1-518:Q4_K_L
ollama rm Qwen3-8B:Q4_K_L
ollama rm Mag-Mell-R1-12B:IQ3_M
ollama list
ollama rm hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q4_K_XL
ollama rm hf.co/EnlistedGhost/Ministral-3-14B-Reasoning-2512-GGUF:Q4_K_XL
ollama create MagMell-R1R-12B:Q5_L -f /home/sera/LLM-Quants/Mag-Mell-Reasoner-12B.modelfile
ollama create MagMell-R1R-12B:Q5_K -f /home/sera/LLM-Quants/Mag-Mell-Reasoner-12B.modelfile
source ~/llama.cpp_3/.env/bin/activate
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/AURORA-R11-GH44/home/sera/hf-models/Magistral-Small-2509/bin --outtype f16 --outfile /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_q=q6_k --tensor-type attn_k=f16 --tensor-type attn_v=f16 --tensor-type attn_output=q8_0 --tensor-type ffn_down=q6_k --tensor-type ffn_up=q6_k --tensor-type ffn_gate=f16 --output-tensor-type q8_0 --token-embedding-type q8_0 /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf Q8_0 8
ollama --version
ollama create Magistral-Small-24B-2509:Q8_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
llama-server -m /run/media/sera/GH44-Ancillary/Magistral-Small-2509-F16.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn
llama-server -m /run/media/sera/GH44-Ancillary/Magistral-Small-2509-F16.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true
llama-server -m /run/media/sera/GH44-Ancillary/Magistral-Small-2509-Q8_0_L.gguf -mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true
llama-server -m /run/media/sera/GH44-Ancillary/Magistral-Small-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --use_mmap false
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --mmap false
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --mmap 0
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --no-mmap
export GGML_VK_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --no-mmap
llama-server -m /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-Q8_0_L.gguf --mmproj /run/media/sera/AUX_AI512/mmproj-Magistral-Small-2509-F32.gguf     --host 127.0.0.1     --port 11434     -ngl 99     -c 23982     --tensor-split 1,1,1,1,1,1,1,1     --split-mode row     --flash-attn true    --no-mmap --min-p 0.5209 --top-p 0.7908 --top-k 95.8207 --temperature 1.15
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ip
ip addr
sudo zypper ref -f
sudo zyooer dup
sudo zypper dup
ip addr
sudo zypper dup
ip addr
sudo zypper dup
ip addr
sudo zypper dup
ip addr
sudo zypper dup
ip addr
sudo zypper dup
ip addr
sudo zypper dup
sudo zypper ref -f
sudo zypper dup
sudo zypper ref -f
sudo zypper dup
sudo zypper clean --all
udo zypper ref -f
sudo zypper ref -f
sudo zypper dup
sudo reboot
sudo zypper verify
sudo rpm -ivh --force --noscripts --nodeps --replacepkgs ~/Downloads/binutils-2.45-3.2.x86_64.rpm
sudo zypper in -f binutils
sudo update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 50
sudo update-alternatives --force --auto ld
sudo zypper dup
sudo zypper addblock binutils
sudo zypper addlock binutils
ls -la /usr/bin/ld
ls -la /etc/alternatives/ld
sudo /usr/lib/nvidia/pre-install
sudo zypper in -f nvidia-video-G06 nvidia-gl-G06 nvidia-gfxG06-kmp-default
modinfo nvidia | head -n 5
modinfo nvidia | head -n 3
sudo reboot
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,4,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo cp -r /home/sera/Downloads/ollama-linux-amd64.tar(2)/bin/ollama /usr/local/bin/ollama
sudo cp -r "/home/sera/Downloads/ollama-linux-amd64.tar(2)/bin/ollama" "/usr/local/bin/ollama"
sudo cp -r "/home/sera/Downloads/ollama-linux-amd64.tar(2)/lib/ollama" "/usr/local/lib/ollama"
sudo rm -r /usr/local/lib/ollama
sudo cp -r "/home/sera/Downloads/ollama-linux-amd64.tar(2)/lib/ollama" "/usr/local/lib/ollama"
ollama --version
/home/sera/Builds/Lilymorphism/Run_Program.sh 
sudo rm -r /usr/local/lib/ollama
/home/sera/.glassmorphism_app/Run_Program.sh
sudo cp -r "/home/sera/Downloads/ollama-0.30.0-rc15-linux-amd64/lib/ollama" "/usr/local/lib/ollama"
sudo cp -r "/home/sera/Downloads/ollama-0.30.0-rc15-linux-amd64/bin/ollama" "/usr/local/bin/ollama"
ollama create Mistral-Small-4-119B:Q2_K_L -f /home/sera/LLM-Quants/hf-Mistral_Small_4_119B.md
ollama list
ollama rm Veiled-Calla-12B:IQ3_M
ollama rm Granite-4.1-8B:IQ3_M
ollamar rm Pixtral-12B-2409:Amber                                    474c62e99161    19 GB     8 weeks ago     
ollama rm Pixtral-12B-2409:Amber
ollama list
ollama rm hf.co/EnlistedGhost/Mag-Mell-Reasoner-12B-GGUF:Q5_K_XL
ollama create Mistral-Small-4-119B:IQ3_M -f /home/sera/LLM-Quants/hf-Mistral_Small_4_119B.md
ollama list
ollama rm Mistral-Small-4-119B:IQ3_X
ollama rm Mistral-Small-4-119B:IQ3_M
llama-gguf-split --merge mistralai_Mistral-Small-4-119B-2603-IQ3_M-00001-of-00002.gguf merge.gguf
llama-gguf-split --merge mistralai_Mistral-Small-4-119B-2603-IQ3_M-00001-of-00002.gguf ../merge.gguf
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/mistralai_Mistral-Small-4-119B-2603-IQ3_M-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/mistralai_Mistral-Small-4-119B-2603-IQ3_M.gguf
ollama create Mistral-Small-4-119B:IQ3_M -f /home/sera/LLM-Quants/hf-Mistral_Small_4_119B.md
ollama list
ollama rm Mistral-Small-4-119B:IQ3_M
cpulimit --pid=27943 --limit=180
sudo zypper install cpulimit
cpulimit --pid=27943 --limit=180
cpulimit --pid=42851 --limit=180
cpulimit --pid=53149 --limit=180
cpulimit --pid=53149 --limit=80
cpulimit --pid=53149 --limit=60
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-UD-IQ4_XS-00002-of-00003.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-IQ4_XS.gguf
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-UD-IQ4_XS-00001-of-00003.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-IQ4_XS.gguf
cpulimit --pid=53149 --limit=80
ollama create Mistral-Small-4-119B:IQ4_XS -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
cpulimit --pid=53149 --limit=60
cpulimit --pid=80523 --limit=60
cpulimit --pid=80523 --limit=80
cpulimit --pid=80523 --limit=140
cpulimit --pid=86511 --limit=140
cpulimit --pid=80523 --limit=140
cpulimit --pid=86511 --limit=120
cpulimit --pid=86511 --limit=100
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-MXFP4_MOE-00001-of-00003.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-MXFP4_MOE.gguf
ollama create Mistral-Small-4-119B:MXFP4 -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
sudo rm -r /usr/local/lib/ollama
sudo cp -r "/home/sera/Downloads/ollama-linux-amd64/lib/ollama" "/usr/local/lib/ollama"
sudo cp -r "/home/sera/Downloads/ollama-linux-amd64/bin/ollama" "/usr/local/bin/ollama"
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
ollama list
ollama rm Mistral-Small-4-119B:MXFP4
cd ~/.github-repos
cd ~/.github_repos
cd ~/.github_repo
cd ~/.github-repo
git clone https://hf.co/wty-yy/humanoid_target_tracking_ckpts
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,4,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,4,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ollama list
ollama --version
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q3_K_XL-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q3_K_XL.gguf
ollama --version
ollama create Mistral-Small-4-119B:Q3_K_XL -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
ollama create Mistral-Small-4-119B:IQ3_M -f /home/sera/LLM-Quants/hf-Mistral_Small_4_119B.md
ollama create Mistral-Small-4-119B:IQ3_M -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo reboot
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh 
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_L-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_L.gguf
ollama create Mistral-Small-4-119B:Q4_K_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
sudo reboot
ollama create Mistral-Small-4-119B:IQ2_M -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
cpulimit --pid=4449 --limit=40
cpulimit --pid=122249 --limit=100
cpulimit --pid=173616 --limit=100
cpulimit --pid=183321 --limit=100
cpulimit --pid=183321 --limit=80
cpulimit --pid=237125 --limit=70
cpulimit --pid=237437 --limit=70
cpulimit --pid=173616 --limit=70
cpulimit --pid=237662 --limit=140
cpulimit --pid=237662 --limit=50
cpulimit --pid=237662 --limit=20
cpulimit --pid=237662 --limit=140
cpulimit --pid=237662 --limit=90
cpulimit --pid=4449 --limit=40
cpulimit --pid=4449 --limit=20
ollama create Mistral-Small-4-119B:Q4_K_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
/home/sera/Builds/Lilymorphism/Run_Program.sh 
ollama rm Mistral-Small-4-119B:Q4_K_L
/home/sera/Builds/Lilymorphism/Run_Program.sh 
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
cpulimit --pid=28389 --limit=90
cpulimit --pid=2708 --limit=60
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphism_app/Run_Program.sh
ollama create Anubis-11B:Q8_0 -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
ollama list
ollama rm hf.co/EnlistedGhost/Anubis-Mini-11B-v1-Vision-OLLAMA:Q8_0
ollama create Pixtral-12B-2409:Q5_K_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
ollama list
ollama pull hf.co/EnlistedGhost/Anubis-Mini-11B-v1-Vision-OLLAMA:Q8_0
ollama pull hf.co/EnlistedGhost/Pixtral-12B-2409-GGUF:Q5_K_XL
ollama pull hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q5_K_XL
ollama create Ministral-3-14B:Q5_K_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/Builds/Lilymorphism/Run_Program.sh 
ollama create Mag-Mell-R1-12B:Q5_K_L -f /home/sera/LLM-Quants/hf-Mag-Mell-R1-12B.modelfile
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
sudo zypper dup
/home/sera/.glassmorphism_app/Run_Program.sh
sudo zypper dup
source ~/llama.cpp_3/.env/bin/activate
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/AURORA-R11-GH44/home/sera/hf-models/Magistral-Small-2509/bin --outtype f16 --outfile /run/media/sera/AUX_AI512/Magistral-Small-24B-2509-F16.gguf
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/AURORA-R11-GH44/home/sera/hf-models/Ministral-3-14B-Instruct-2512-BF16 --outtype f16 --outfile ~/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf
llama-quantize --tensor-type attn_norm=q5_k --tensor-type attn_output=q4_k --tensor-type attn_q=q4_k --tensor-type attn_k=q6_k --tensor-type attn_v=q6_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --output-tensor-type q6_k --token-embedding-type q5_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q4_K_M.gguf Q4_K_M 6
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q5_k --tensor-type attn_q=q5_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --output-tensor-type q8_0 --token-embedding-type q8_0 ~/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q4_K_XL.gguf Q4_K_M 4
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_output=q4_k --tensor-type attn_q=q4_k --tensor-type attn_k=q4_k --tensor-type attn_v=q4_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --output-tensor-type q5_k --token-embedding-type q4_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q4_K_S.gguf Q4_K_S 3
llama-quantize --tensor-type attn_norm=q3_k --tensor-type attn_output=q3_k --tensor-type attn_q=q3_k --tensor-type attn_k=q3_k --tensor-type attn_v=q3_k --tensor-type ffn_gate=q4_k --tensor-type ffn_down=q3_k --tensor-type ffn_up=q3_k --output-tensor-type q5_k --token-embedding-type q4_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q3_K_S.gguf Q3_K_S 3
llama-quantize --tensor-type attn_norm=q5_k --tensor-type attn_output=q3_k --tensor-type attn_q=q3_k --tensor-type attn_k=q4_k --tensor-type attn_v=q4_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q3_k --tensor-type ffn_up=q3_k --output-tensor-type q6_k --token-embedding-type q5_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q3_K_M.gguf Q3_K_M 3
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q5_k --tensor-type attn_q=q4_k --tensor-type attn_k=q5_k --tensor-type attn_v=q5_k --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q3_k --tensor-type ffn_up=q3_k --output-tensor-type q8_0 --token-embedding-type q6_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q3_K_L.gguf Q3_K_M 3
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_output=q5_k --tensor-type attn_q=q4_k --tensor-type attn_k=q6_k --tensor-type attn_v=q6_k --tensor-type ffn_gate=q8_0 --tensor-type ffn_down=q4_k --tensor-type ffn_up=q4_k --output-tensor-type q8_0 --token-embedding-type q8_0 /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q3_K_XL.gguf Q3_K_L 3
llama-quantize --tensor-type attn_norm=q2_k --tensor-type attn_output=q2_k --tensor-type attn_q=q2_k --tensor-type attn_k=q2_k --tensor-type attn_v=q2_k --tensor-type ffn_gate=q2_k --tensor-type ffn_down=q2_k --tensor-type ffn_up=q2_k --output-tensor-type q4_k --token-embedding-type q3_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K_S.gguf Q2_K_S 3
llama-quantize --tensor-type attn_norm=q3_k --tensor-type attn_output=q3_k --tensor-type attn_q=q2_k --tensor-type attn_k=q3_k --tensor-type attn_v=q3_k --tensor-type ffn_gate=q2_k --tensor-type ffn_down=q2_k --tensor-type ffn_up=q2_k --output-tensor-type q4_k --token-embedding-type q3_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K_S.gguf Q2_K_S 3
llama-quantize --tensor-type attn_norm=q3_k --tensor-type attn_output=q3_k --tensor-type attn_q=q2_k --tensor-type attn_k=q3_k --tensor-type attn_v=q3_k --tensor-type ffn_gate=q2_k --tensor-type ffn_down=q2_k --tensor-type ffn_up=q2_k --output-tensor-type q4_k --token-embedding-type q3_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K_S.gguf Q2_K_M 3
llama-quantize --tensor-type attn_norm=q3_k --tensor-type attn_output=q3_k --tensor-type attn_q=q2_k --tensor-type attn_k=q3_k --tensor-type attn_v=q3_k --tensor-type ffn_gate=q2_k --tensor-type ffn_down=q2_k --tensor-type ffn_up=q2_k --output-tensor-type q4_k --token-embedding-type q3_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K_S.gguf Q2_K 3
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_output=q3_k --tensor-type attn_q=q2_k --tensor-type attn_k=q3_k --tensor-type attn_v=q3_k --tensor-type ffn_gate=q3_k --tensor-type ffn_down=q2_k --tensor-type ffn_up=q2_k --output-tensor-type q5_k --token-embedding-type q4_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K.gguf Q2_K 3
llama-quantize --tensor-type attn_norm=q4_k --tensor-type attn_output=q3_k --tensor-type attn_q=q2_k --tensor-type attn_k=q4_k --tensor-type attn_v=q4_k --tensor-type ffn_gate=q4_k --tensor-type ffn_down=q3_k --tensor-type ffn_up=q3_k --output-tensor-type q8_0 --token-embedding-type q6_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q2_K_L.gguf Q2_K 3
llama-quantize --tensor-type attn_norm=q5_k --tensor-type attn_output=q5_k --tensor-type attn_q=q5_k --tensor-type attn_k=q6_k --tensor-type attn_v=q6_k --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q6_k --token-embedding-type q6_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q5_K_M.gguf Q5_K_M 5
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q8_0 --token-embedding-type q8_0 /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q5_K_XL.gguf Q5_K_M 5
llama-quantize --tensor-type attn_norm=q5_k --tensor-type attn_output=q5_k --tensor-type attn_q=q4_k --tensor-type attn_k=q6_k --tensor-type attn_v=q6_k --tensor-type ffn_gate=q5_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q6_k --token-embedding-type q5_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q5_K_S.gguf Q5_K_S 5
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q6_k --tensor-type attn_v=q6_k --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q6_k --tensor-type ffn_up=q6_k --output-tensor-type q6_k --token-embedding-type q6_k /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q6_K.gguf Q6_K 5
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q8_0 --tensor-type ffn_down=q6_k --tensor-type ffn_up=q6_k --output-tensor-type q8_0 --token-embedding-type q8_0 /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q6_K_L.gguf Q6_K 5
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_output=q8_0 --tensor-type attn_q=q8_0 --tensor-type attn_k=f16 --tensor-type attn_v=f16 --tensor-type ffn_gate=f16 --tensor-type ffn_down=q8_0 --tensor-type ffn_up=q8_0 --leave-output-tensor --token-embedding-type f16 /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q8_0_L.gguf Q8_0 5
llama-quantize --tensor-type attn_norm=q8_0 --tensor-type attn_output=q8_0 --tensor-type attn_q=q8_0 --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q8_0 --tensor-type ffn_down=q8_0 --tensor-type ffn_up=q8_0 --output-tensor-type q8_0 --token-embedding-type q8_0 /home/sera/LLM-Quants/Ministral-3-14B-Instruct-2512-F16.gguf /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512-Q8_0.gguf Q8_0 5
hf upload --commit-message "Updated Tokenizer Template (Chat Template) to directly support llama.cpp" EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512
hf update
pip install --upgrade pip
hf upload --commit-message "Updated Tokenizer Template (Chat Template) to directly support llama.cpp" EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF /run/media/sera/AUX_AI512/Ministral-3-14B-Instruct-2512
ollama rm  hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q5_K_XL 
ollama rm  Ministral-3-14B:Q5_K_L 
ollama rm  Mistral-Small-4-119B:IQ2_M 
ollama rm  Mistral-Small-4-119B:Q2_K_L 
ollama rm  Magistral-Small-24B-2509:Q8_L 
ollama rm  Pixtral-12B-2409:Q5_K_L 
ollama list
ollama rm Mag-Mell-R1-12B:Q4_K_L
ollama rm MgMell-GnRR-12B:Q4L
ollama rm MagMell-GnRRGA-12B:Q5L
ollama rm Mistral-Small-4-119B:Q3_K_XL
ollama rm Qwen3.5-9B:Onyx
ollama list
ollama rm Devstral-2507:Q4_K_M
ollama rm Veiled-Calla-12B:Q4_K_L
ollama rm Aurelias-12B:Q4
source ~/llama.cpp_3/.env/bin/activate
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_S-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_S.gguf
ollama create Mistral-Small-4-119B:Q4_K_S -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
ollama --version
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ollama list
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_L-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Small-4-119B-2603-Q4_K_L.gguf
ollama list
ollama create Mistral-Small-4-119B:Q4_S -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
ollama rm Mistral-Small-4-119B:Q4_K_S
ollama list
ollama rm Anubis-11B:Q8_0 
ollama create Mistral-Small-4-119B:Q4_K_L -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
ollama pull hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q4_K_XL
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ollama list
ollama rm hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q4_K_XL
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Medium-3.5-128B-IQ3_M-00002-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Medium-3.5-128B-IQ3_M.gguf
llama-gguf-split --merge /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Medium-3.5-128B-IQ3_M-00001-of-00002.gguf /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/Mistral-Medium-3.5-128B-IQ3_M.gguf
ollama create Mistral-Medium-3.5:IQ3_M -f /home/sera/LLM-Quants/Magistral-Small-1.2-Q8_L.md
sudo firewall-cmd --add-port=5005/tcp --permanent
sudo firewall-cmd --add-port=5001/tcp --permanent
sudo firewall-cmd --add-port=5005/tcp --permanent
sudo firewall-cmd --reload
/home/sera/.glassmorphism_app/Run_Program.sh
cpulimit --pid=19883 --limit=60
cpulimit --pid=19883 --limit=90
cpulimit --pid=19883 --limit=120
ollama list
ollama rm Mistral-Small-4-119B:IQ4_XS
ollama rm Mistral-Small-4-119B:Q4_S
ollama pull hf.co/EnlistedGhost/Ministral-3-14B-Instruct-2512-GGUF:Q6_K_L
ollama pull hf.co/mradermacher/Huihui-Qwen3.5-9B-abliterated-i1-GGUF:Q5_K_M
ollama pull hf.co/mradermacher/Qwen3.5-9B-RpRMax-v1-GGUF:Q5_K_M
source ~/llama.cpp_3/.env/bin/activate
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/AUX_AI2TB/AURORA-R11-GH44/home/sera/hf-models/Veiled-Calla-12B --outtype bf16 --outfile /run/media/sera/AUX_AI2TB/Veiled-Calla-12B-BF16.gguf
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/AUX_AI2TB/AURORA-R11-GH44/home/sera/hf-models/Veiled-Calla-12B --outtype f32 --outfile /run/media/sera/AUX_AI2TB/Veiled-Calla-12B-F32.gguf
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q8_0 --token-embedding-type q8_0 /run/media/sera/AUX_AI2TB/Veiled-Calla-12B-F32.gguf /run/media/sera/AUX_AI512/Veiled-Calla-12B--Q5_K_L.gguf Q5_K_M 5
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/GH44-Ancillary/AURORA-R11-GH44/home/sera/hf-models/Aurelias-Garden-12b --outtype f16 --outfile /run/media/sera/AUX_AI512/Aurelias-Garden-12b-F16.gguf
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/AUX_AI2TB/AURORA-R11-GH44/home/sera/hf-models/Veiled-Calla-12B --mmproj --outtype f32 --outfile /run/media/sera/AUX_AI2TB/mmproj-Veiled-Calla-12B-F32.gguf
ollama create Veiled-Calla-12B:Q5_L -f /home/sera/LLM-Quants/hf-Veiled-Calla-12B.modelfile
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q8_0 --token-embedding-type q8_0 /run/media/sera/AUX_AI512/Aurelias-Garden-12b-F16.gguf /run/media/sera/AUX_AI512/Aurelias-Garden-12b-Q5_K_L.gguf Q5_K_M
llama-quantize --tensor-type attn_norm=q6_k --tensor-type attn_output=q6_k --tensor-type attn_q=q6_k --tensor-type attn_k=q8_0 --tensor-type attn_v=q8_0 --tensor-type ffn_gate=q6_k --tensor-type ffn_down=q5_k --tensor-type ffn_up=q5_k --output-tensor-type q8_0 --token-embedding-type q8_0 /run/media/sera/AUX_AI512/Aurelias-Garden-12b-F16.gguf /run/media/sera/AUX_AI512/Aurelias-Garden-12b-Q5_K_L.gguf Q5_K_M 3
python3 /home/sera/llama.cpp_3/convert_hf_to_gguf.py /run/media/sera/GH44-Ancillary/AURORA-R11-GH44/home/sera/hf-models/Aurelias-Garden-12b --mmproj --outtype f32 --outfile /run/media/sera/AUX_AI512/mmproj-Aurelias-Garden-12b-F32.gguf
ollama create Aurelias-Garden-12B:Q5_L -f /home/sera/LLM-Quants/hf-Aurelias-Garden-12B.modelfile
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/Builds/Lilymorphism/Run_Program.sh
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ip addr
/home/sera/.glassmorphism_app/Run_Program.sh
ip addr
sudo firewall-cmd --add-port=11434/tcp --permanent
sudo firewall-cmd --reload
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=192.168.1.184:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=0.0.0.0:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
sudo zypper dup
sudo zypper install /home/sera/Downloads/vulkan-headers-1.4.350-1.1.noarch.rpm
sudo zypper dup
sudo reboot
/home/sera/.glassmorphism_app/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=127.0.0.1:11434 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
ip addr
/home/sera/.glassmorphism_app/Run_Program.sh
source ~/comfy/ComfyUI/venv/.env/bin/activate
python3 /home/sera/comfy/ComfyUI/main.py
/home/sera/.glassmorphism_app/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/Builds/Lilymorphism/Run_Program.sh
sudo snapper rollback
sudo reboot
ollama pull hf.co/EnlistedGhost/Pixtral-12B-2409-GGUF:Q5_K_XL
ollama pull hf.co/EnlistedGhost/Ministral-3-8B-Instruct-2512-GGUF:Q5_K_XL
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphism_app/Run_Program.sh
sudo chmod -R 777 /run/media/sera/6277518e-059f-4856-a310-4400bc1dc5ae/AURORA-R11-GH44/home/sera
/home/sera/Builds/Lilymorphism/Run_Program.sh
nano /home/sera/Builds/Lilymorphism/Run_Program.sh
/home/sera/Builds/Lilymorphism/Run_Program.sh
export CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8
/home/sera/Builds/Lilymorphism/Run_Program.sh
OLLAMA_NEW_ENGINE=0 OLLAMA_NEW_ESTIMATES=0 OLLAMA_KEEP_ALIVE=995m OLLAMA_NOHISTORY=1 OLLAMA_FLASH_ATTENTION=1 OLLAMA_MULTIUSER_CACHE=1 OLLAMA_LOAD_TIMEOUT=10m0s OLLAMA_MAX_LOADED_MODELS=1 OLLAMA_NUM_PARALLEL=0 OLLAMA_SCHED_SPREAD=1 OLLAMA_USE_MLOCK=1 OLLAMA_NO_MMAP=0 OLLAMA_NO_CLOUD=1 OLLAMA_CONTEXT_LENGTH=23982 OLLAMA_LLM_LIBRARY=cuda_v12 CUDA_VISIBLE_DEVICES=1,2,3,4,5,6,7,8 ENABLE_ASYNC_EMBEDDING=1 OLLAMA_INTEL_GPU=0 OLLAMA_NUM_BATCH=128 OLLAMA_NUM_CTX=23982 OLLAMA_HOST=0.0.0.0 OLLAMA_ORIGINS=* OLLAMA_MODELS=~/.ollama/models ollama serve
/home/sera/.glassmorphic/.glassmorphism_app/Run_Program.sh
/home/sera/.glassmorphic/GlassMorphism_Engine_Start.sh
chmod a+x /home/sera/.glassmorphic/GlassMorphism_Engine_Start.sh
/home/sera/.glassmorphic/GlassMorphism_Engine_Start.sh
/home/sera/.glassmorphic/.glassmorphism_app/Run_Program.sh
cd /home/sera/.glassmorphic/.glassmorphism_app/app/model_runner
make -j$(4)
make -j4
sudo make -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
sudo nano /usr/local/cuda/targets/x86_64-linux/include/crt/math_functions.h
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j4
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j2
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
make clean -j4
make -j1
/home/sera/.glassmorphic/.glassmorphism_app/Run_Program.sh
