# 第2章 ユーザモードで実現する機能

## システムコール

各種プロセスはシステムコールという手段でカーネルに処理を依頼。


```sh
$ cc -o hello hello.c
$ ./hello
hello world

$ strace -o hello.log ./hello
hello world

$ cat hello.log
execve("./hello", ["./hello"], [/* 9 vars */]) = 0
brk(NULL)                               = 0x17c4000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=14510, ...}) = 0
mmap(NULL, 14510, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f8b430e7000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\t\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1868984, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f8b430e6000
mmap(NULL, 3971488, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f8b42afc000
mprotect(0x7f8b42cbc000, 2097152, PROT_NONE) = 0
mmap(0x7f8b42ebc000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1c0000) = 0x7f8b42ebc000
mmap(0x7f8b42ec2000, 14752, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f8b42ec2000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f8b430e5000
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f8b430e4000
arch_prctl(ARCH_SET_FS, 0x7f8b430e5700) = 0
mprotect(0x7f8b42ebc000, 16384, PROT_READ) = 0
mprotect(0x600000, 4096, PROT_READ)     = 0
mprotect(0x7f8b430eb000, 4096, PROT_READ) = 0
munmap(0x7f8b430e7000, 14510)           = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
brk(NULL)                               = 0x17c4000
brk(0x17e5000)                          = 0x17e5000
# write()システムコールで文字列を画面出力
write(1, "hello world\n", 12)           = 12
exit_group(0)                           = ?
+++ exited with 0 +++
```

### 実験

プロセスがユーザモードとカーネルモードのどちらで実行しているか

```sh
$ sar -P ALL 1

Linux 4.9.125-linuxkit (8c8eebf1249b)   12/27/18        _x86_64_        (2 CPU)

10:51:38        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:39        all      0.51      0.00      0.00      0.00      0.00     99.49
10:51:39          0      0.00      0.00      0.00      0.00      0.00    100.00
10:51:39          1      1.01      0.00      0.00      0.00      0.00     98.99

10:51:39        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:40        all      0.50      0.00      1.00      0.00      0.00     98.50
10:51:40          0      0.00      0.00      1.00      0.00      0.00     99.00
10:51:40          1      1.00      0.00      1.00      0.00      0.00     98.00

10:51:40        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:41        all      0.00      0.00      1.01      0.00      0.00     98.99
10:51:41          0      0.00      0.00      1.00      0.00      0.00     99.00
10:51:41          1      0.00      0.00      1.01      0.00      0.00     98.99

10:51:41        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:42        all      0.50      0.00      0.50      0.00      0.00     98.99
10:51:42          0      0.00      0.00      0.00      0.00      0.00    100.00
10:51:42          1      1.00      0.00      1.00      0.00      0.00     98.00

10:51:42        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:43        all      0.00      0.00      0.00      0.00      0.00    100.00
10:51:43          0      0.00      0.00      0.00      0.00      0.00    100.00
10:51:43          1      0.00      0.00      0.00      0.00      0.00    100.00

10:51:43        CPU     %user     %nice   %system   %iowait    %steal     %idle
10:51:44        all      0.00      0.00      0.51      0.00      0.00     99.49
10:51:44          0      0.00      0.00      1.00      0.00      0.00     99.00
10:51:44          1      0.00      0.00      0.00      0.00      0.00    100.00
^C


Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.25      0.00      0.50      0.00      0.00     99.24
Average:          0      0.00      0.00      0.50      0.00      0.00     99.50
Average:          1      0.51      0.00      0.51      0.00      0.00     98.99
```

実行している時間の割合

|    |    |
| ---- | ---- |
| ユーザモード   | %user + %nice |
| カーネルモード | %system |
| アイドル状態   | %idle |


プログラムを走らせた状態でsar

```sh
$ sar -P ALL 1 1
Linux 4.9.125-linuxkit (8c8eebf1249b)   12/27/18        _x86_64_        (2 CPU)

11:01:52        CPU     %user     %nice   %system   %iowait    %steal     %idle
11:01:53        all      0.00      0.00      0.00      0.00      0.00    100.00
11:01:53          0      0.00      0.00      0.00      0.00      0.00    100.00
11:01:53          1      0.00      0.00      0.00      0.00      0.00    100.00

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all      0.00      0.00      0.00      0.00      0.00    100.00
Average:          0      0.00      0.00      0.00      0.00      0.00    100.00
Average:          1      0.00      0.00      0.00      0.00      0.00    100.00

$ cc -o loop loop.c
$ ./loop &
[1] 33
$ sar -P ALL 1 1
Linux 4.9.125-linuxkit (8c8eebf1249b)   12/27/18        _x86_64_        (2 CPU)

11:00:55        CPU     %user     %nice   %system   %iowait    %steal     %idle
11:00:56        all     50.25      0.00      0.00      0.00      0.00     49.75
11:00:56          0    100.00      0.00      0.00      0.00      0.00      0.00
11:00:56          1      0.00      0.00      0.00      0.00      0.00    100.00

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all     50.25      0.00      0.00      0.00      0.00     49.75
Average:          0    100.00      0.00      0.00      0.00      0.00      0.00
Average:          1      0.00      0.00      0.00      0.00      0.00    100.00
```

loopを走らせた状態だとユーザプロセスが動作。

```sh
$ cc -o ppidloop ppidloop.c
$ ./ppidloop &
[1] 44

Linux 4.9.125-linuxkit (8c8eebf1249b)   12/27/18        _x86_64_        (2 CPU)

11:06:09        CPU     %user     %nice   %system   %iowait    %steal     %idle
11:06:10        all     22.00      0.00     28.50      0.00      0.00     49.50
11:06:10          0     44.00      0.00     56.00      0.00      0.00      0.00
11:06:10          1      0.00      0.00      1.00      0.00      0.00     99.00

Average:        CPU     %user     %nice   %system   %iowait    %steal     %idle
Average:        all     22.00      0.00     28.50      0.00      0.00     49.50
Average:          0     44.00      0.00     56.00      0.00      0.00      0.00
Average:          1      0.00      0.00      1.00      0.00      0.00     99.00
```

%user -> ループの処理
%system -> getppidの処理

### システムコールの所要時間
`strace -T`で調べる

```sh
$ strace -T -o hello.log ./hello  yy
hello world
$ cat hello.log
execve("./hello", ["./hello", "yy"], [/* 9 vars */]) = 0 <0.000948>
brk(NULL)                               = 0x14d3000 <0.000118>
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory) <0.000150>
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory) <0.000153>
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3 <0.000262>
fstat(3, {st_mode=S_IFREG|0644, st_size=14510, ...}) = 0 <0.000177>
mmap(NULL, 14510, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fed863b8000 <0.000035>
close(3)                                = 0 <0.000247>
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory) <0.000166>
open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3 <0.000173>
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0P\t\2\0\0\0\0\0"..., 832) = 832 <0.000077>
fstat(3, {st_mode=S_IFREG|0755, st_size=1868984, ...}) = 0 <0.000118>
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fed863b7000 <0.000146>
mmap(NULL, 3971488, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fed85dcd000 <0.000189>
mprotect(0x7fed85f8d000, 2097152, PROT_NONE) = 0 <0.000152>
mmap(0x7fed8618d000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1c0000) = 0x7fed8618d000 <0.000133>
mmap(0x7fed86193000, 14752, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fed86193000 <0.000129>
close(3)                                = 0 <0.000159>
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fed863b6000 <0.000161>
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fed863b5000 <0.000183>
arch_prctl(ARCH_SET_FS, 0x7fed863b6700) = 0 <0.000128>
mprotect(0x7fed8618d000, 16384, PROT_READ) = 0 <0.000133>
mprotect(0x600000, 4096, PROT_READ)     = 0 <0.000115>
mprotect(0x7fed863bc000, 4096, PROT_READ) = 0 <0.000113>
munmap(0x7fed863b8000, 14510)           = 0 <0.000117>
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0 <0.000106>
brk(NULL)                               = 0x14d3000 <0.000126>
brk(0x14f4000)                          = 0x14f4000 <0.000116>
write(1, "hello world\n", 12)           = 12 <0.000114>
exit_group(0)                           = ?
+++ exited with 0 +++
```

## システムコールのラッパー関数
システムコールはアーキテクチャ依存のアセンブリコードを用いて呼び出す必要がある。
OSは内部的にシステムコールを呼び出すだけのラッパーを提供している。
ほとんどのCプログラムはglibcをリンクしており、`ldd`コマンドでリンクしているライブラリを確かめることができる。


```sh
$ ldd /bin/echo
linux-vdso.so.1 =>  (0x00007ffdb1ffe000)
libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f99c9268000)
/lib64/ld-linux-x86-64.so.2 (0x00007f99c9632000)
```

echoはlibcとリンクしていることがわかった。

## OSが提供するプログラム

OSが提供するプログラムには次のようなものがある。
- システムの初期化: init
- OSの挙動を帰る: sysctl, nice, sync
- ファイル操作: touch, mkdir
- テキストデータの加工: grep, sort, uniq
- 性能測定: sar, iostat
- コンパイラ: gcc
- スクリプト実行環境: perl, ruby, python
- シェル: bash
- ウインドウシステム: X
