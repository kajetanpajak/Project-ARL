Clone the repository and build the image:

```bash
git clone https://github.com/kajetanpajak/Project-ARL.git
cd ARL-project/docker
bash px4_build.sh
```

Run the container:

```bash
bash px4_run_gpu_nvidia.sh
```

The repository is mounted at `/workspace`.
