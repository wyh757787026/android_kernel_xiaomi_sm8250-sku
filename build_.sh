#!/bin/bash
#告诉编译器你构建的是arm64的内核，如果你不是64位的，那就把64删掉
export ARCH=arm64
export SUBARCH=arm64

#配置之前同步好的内核编译器环境变量，让当前环境可以直接使用
#/home/sir/pstar/kernel/clang是clang编译器的路径
#它下面的bin则是可执行二进制文件存放的文件夹，我们需要调用这个里面的程序来开始构建内核
export PATH="/mnt/tools/clang/bin:/mnt/tools/gcc64/bin:/mnt/tools/gcc32/bin:$PATH"

args="-j$(nproc --all) \
ARCH=arm64 \
SUBARCH=arm64 \
O=out \
CC=clang \
CROSS_COMPILE=aarch64-linux-android- \
CROSS_COMPILE_ARM32=arm-linux-androideabi- \
CLANG_TRIPLE=aarch64-linux-gnu- "
#负责交叉编译的Linux编译器
#这个也不清楚干嘛用的，就是它在构建的时候，需要用到Linux的一些标准库内容
#但是安卓的编译器阉割了，直接用安卓的编译，会出现很多莫名其妙的错误，所以就需要再配置一下这个编译器了
#如果你的设备是32位的，这里也要修改的

#清理之前构建的残留内容
make clean && make mrproper
#删除out文件夹，也就是之前指定输出的文件夹
rm -rf out 
#新建out文件夹，用来保存临时产生的垃圾文件还有最终生成的内核文件
mkdir -p out

#先检测配置文件有没有问题，进行初次构建
make ${args} vendor/cmi_defconfig 
#这里如果不加vendor，就会读取
#内核源码/arch/你的设备架构/configs/里面的配置文件
#这个完整路径为: 内核源码/arch/你的设备架构/configs/vendor/lineageos_pstar_defconfig 
#不加vendor的完整路径为:内核源码/arch/你的设备架构/configs/lineageos_pstar_defconfig 

#这里的args就是上面设置的临时变量args里面的内容
#开始构建内核
make ${args} 
