## How to build Tensorflow from the source, the shortcut

1. Setup build environment

- Download tensorflow docker development image

```shell
docker pull tensorflow/tensorflow:devel-py3
```

- Run tensorflow image and mount shared volume for copying the result wheel file at the end

```shell
docker run -it -w /tensorflow -v D:\Share:/share tensorflow/tensorflow:devel-py3 bash
```

2. Get the latest tensorflow version and finish environment setup
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

3. Configure bazel for the target CPU

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
``march=silvermont`` for Celeron Bay Trail CPU











<script src="https://utteranc.es/client.js"
        repo="blog.glushkov.net"
        issue-term="title"
        theme="photon-dark"
        crossorigin="anonymous"
        async>
</script>
