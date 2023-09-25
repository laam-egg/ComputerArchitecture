# MIPS

## Dialects

<https://www.linux-mips.org/wiki/WhatsWrongWithO32N32N64>

 - o32: For 32-bit CPU's
 - n32: For 64-bit CPU's, uses 32-bit addresses, supports long integers
 - n64: For 64-bit CPU's, uses 64-bit addresses, supports long integers

## Development Environment Setup

### Linux

```sh
sudo apt install gcc-mips-linux-gnu
sudo apt install qemu
sudo apt install qemu-user
```

## Compiling and Running MIPS programs

### Compiling

```sh
mips-linux-gnu-as hello.s -o build/hello.o
mips-linux-gnu-gcc build/hello.o -o build/hello -nostdlib -static
```

### Running

```sh
qemu-mips build/hello
# Print exit code
echo $?
```

## Syscalls
<https://syscalls.w3challs.com/?arch=mips_o32>

Residence of values:

|  System Call Code   |                    Parameters                  |
| :-----------------: | :--------------------------------------------: |
|        `$v0`        |            `$a0`, `$a1`, `$a2`, `$a3`          |

Some system call codes:

| `$v0` | System call |   `$a0`   |     `$a1`     |   `$a2`  |  `$a3`  |
| ----: | :---------- | :-------: | :-----------: | :------: | :-----: |
|  4001 | exit        | `int`     |       -       |     -    |    -    |
|  4003 | read        | `uint fd` |    `char*`    | `size_t` |    -    |
|  4004 | write       | `uint fd` | `char const*` | `size_t` |    -    |

## File Descriptors (fd)

	0: stdin
	1: stdout
	2: stderr

