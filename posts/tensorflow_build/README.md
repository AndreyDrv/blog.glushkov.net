## How to build Tensorflow from the source, the shortcuts / Build Tensorflow for the older CPU / Tensorflow build Troubleshooting

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

```bash
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
CPU instructions could be also disabled.
The full flags list is [here](https://gcc.gnu.org/onlinedocs/gcc-4.5.3/gcc/i386-and-x86_002d64-Options.html)

#### 4. Build with bazel for the target CPU (~3,5h docker 8GB RAM 4 CPU)
Using the flags from step 3 assembling the build line

Example with overriding the march flag
```shell
bazel build --copt=-march=silvermont //tensorflow/tools/pip_package:build_pip_package
```

Example with forced and restricted flags
```shell
bazel build --config=opt --copt=-mssse3 --copt=-mcx16 --copt=-msse4.1 --copt=-msse4.2 --copt=-mpopcnt --copt=-mno-fma4 --copt=-mno-avx --copt=-mno-avx2 //tensorflow/tools/pip_package:build_pip_package
```

#### 5. Wrap the binaries with python setup wheel file

Generate wheel file to the shared directory
```
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /share/tf_compile/tensorflow_src/compiled/
```

Now the setup file ex:`tensorflow-2.1.0-cp36-cp36m-linux_x86_64.whl` is ready to be installed / deployed on the target environment.


#### 6. Install Tensorflow and verify with hello-world example

Ex:
```
python3.6 -m pip install /tensorflow-2.1.0-cp36-cp36m-linux_x86_64.whl
```

Verify Tensorflow is working (v2.XX)
```
python3.6 -c "import tensorflow as tf; msg = tf.constant('TensorFlow 2.0 Hello World'); tf.print(msg)"
```

Verify Tensorflow is working (v1.XX)
```
python3.6 -c "from __future__ import print_function; import tensorflow as tf; hello = tf.constant('Hello, TensorFlow!'); sess = tf.Session(); print(sess.run(hello))"
```


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

###### Avoid errors like 'CXXABI_1.3.11' not found when Tensorflow is successfully installed by fail to run

To check if the target has the required API version ex:`CXXABI_1.3.11`
```
strings /usr/lib/x86_64-linux-gnu/libstdc++.so.6 | grep CXXABI
```
If the `1.3.11` is missing, do one of the following steps:

- Add the parameter to the build line to enable compatability with older GCC
```
bazel build --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" ...
```

- If the file was already compiled and the platform is matching, need a quick fix just copy `/usr/lib/x86_64-linux-gnu/libstdc++.so.6` file from tensorflow development docker container (from step 1) to the target PC environment to the same path `/usr/lib/x86_64-linux-gnu/` or `/usr/lib64` depending on the target system.


###### Illegal instruction Tensorflow error after running
The build flags were not properly selected / skipped - the compiled binaries and the target CPU does not match
Try to refine `-march` flag; disable unsupported instructions ex:`-mno-avx`, etc at step 4.
