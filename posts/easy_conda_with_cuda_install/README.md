```bash
conda create --name tf_gpu354 python=3.5.4 pip cudatoolkit=9.0 tensorflow-gpu
conda install -c conda-forge keras==2.2.0
conda install pillow
conda install pandas==0.23.4
pip install opencv-python==3.4.3.18
```
# do not install tensorflow from pip! (even if it asks)
