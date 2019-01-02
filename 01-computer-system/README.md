# 第 1 章 コンピュータシステムの概要

コンピュータシステムが動作するとき、ハードウェア上では、

1. 入力デバイスやネットワークアダプタを介してコンピュータに処理を依頼
2. メモリ上に存在する命令を読み出してCPUにおいて実行、結果をメモリ上のデータを保持する領域に書き込む。
3. メモリ上のデータをストレージに書き込んだり、ネットワークを介して他のコンピュータに転送したりする。
4. 1.に戻る


```puml
actor User
node Computer{
    package NarrowComputer{
        node CPU
        node Memory
    }
    package device{
        node IOdevice{
            [Display]
            [Keyboard]
        }
        node Storage{
        }
        node NetworkAdapter{

        }
    }
}
note top of Computer
    コンピュータシステムの
    ハードウェア構成
end note
cloud Network
node AnotherComputer{

}

User <--> IOdevice
Network <--> NetworkAdapter
Network <--> AnotherComputer
CPU <-> Memory
NarrowComputer <--> device
```

Linuxではデバイスを操作する処理をデバイスドライバにまとめていて、
プロセスからデバイスへのアクセスはデバイスドライバを介して行われる。

ハードウェアの力を借りて、デバイスには直接アクセスできないような仕組みがあり、
具体的には、CPUにはカーネルモードとユーザモードという2つのモードがあり、
カーネルモードで動作している時だけデバイスにアクセスできる。
デバイスドライバはカーネルモードで動作して、プロセスはユーザモードで動作する。

デバイス以外にも、プロセス管理システムやプロセススケジューラ、メモリ管理システムなどはカーネルモードで動作する。
このようなカーネルモードで動作するOSの核となる処理をまとめたプログラムをカーネルと呼ぶ。プロセスはカーネルにシステムコールと呼ばれる特殊な処理を介してカーネルに依頼をする。
