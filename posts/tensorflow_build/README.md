## How to build Tensorflow from the source, the shortcut

#### 1. Setup build environment

- Download tensorflow docker development image

```shell
docker pull tensorflow/tensorflow:devel-py3
```

- Run tensorflow image and mount shared volume for copying the result wheel file at the end

```shell
docker run -it -w /tensorflow -v D:\Share:/share tensorflow/tensorflow:devel-py3 bash
```

#### 2. Get the latest tensorflow version and finish environment setup
Inside the container or local folder (if instead step 1 the environment was set up manually)

```shell
cd /tensorflow_src/
git pull
git checkout r2.1
```

Install python dependancies for the build

```shell
pip3 install six numpy wheel
pip3 install keras_applications==1.0.6 --no-deps
pip3 install keras_preprocessing==1.0.5 --no-deps
```

#### 3. Configure bazel / understand flags for the target CPU

```shell
python configure.py
```

Answer the questions and put the proper compilation flags at the end:
```
Found possible Python library paths:
  /usr/local/lib/python3.6/dist-packages
  /usr/lib/python3/dist-packages
Please input the desired Python library path to use.  Default is [/usr/local/lib/python3.6/dist-packages]

Do you wish to build TensorFlow with XLA JIT support? [Y/n]: n
No XLA JIT support will be enabled for TensorFlow.

Do you wish to build TensorFlow with OpenCL SYCL support? [y/N]:
No OpenCL SYCL support will be enabled for TensorFlow.

Do you wish to build TensorFlow with ROCm support? [y/N]:
No ROCm support will be enabled for TensorFlow.

Do you wish to build TensorFlow with CUDA support? [y/N]:
No CUDA support will be enabled for TensorFlow.

Do you wish to download a fresh release of clang? (Experimental) [y/N]:
Clang will not be downloaded.

Please specify optimization flags to use during compilation when bazel option "--config=opt" is specified [Default is -march=native -Wno-sign-compare]: -march=silvermont


Would you like to interactively configure ./WORKSPACE for Android builds? [y/N]:
Not configuring the WORKSPACE for Android builds.
```
`-march=silvermont` for Celeron Bay Trail CPU

*(info)* To get the CPU code for gcc:
```shell
cat /sys/devices/cpu/caps/pmu_name
```

*(info)* To get the flags list only if the CPU code is wrong or does not work as expected:
Run on the target PC/CPU
```
grep flags -m1 /proc/cpuinfo | cut -d ":" -f 2 | tr '[:upper:]' '[:lower:]' | { read FLAGS; OPT="-march=native"; for flag in $FLAGS; do case "$flag" in "sse4_1" | "sse4_2" | "ssse3" | "fma" | "cx16" | "popcnt" | "avx" | "avx2") OPT+=" -m$flag";; esac; done; MODOPT=${OPT//_/\.}; echo "$MODOPT"; }
```
The output will be in the format `-march=native -mssse3 -mcx16 -msse4.1 -msse4.2 -mpopcnt`

The flags list is 



#### Troubleshooting
###### Bazel is not the right version / update Bazel

Download the installation script for the required version and platform and install
```
./bazel-1.2.1-installer-linux-x86_64.sh
```

*!* Installation of the deb file does not work from the box as need to reassign binary shotcuts versions.
```
sudo apt install ./bazel_1.2.1-linux-x86_64.deb
```



<script src="https://utteranc.es/client.js"
        repo="blog.glushkov.net"
        issue-term="title"
        theme="photon-dark"
        crossorigin="anonymous"
        async>
</script>
