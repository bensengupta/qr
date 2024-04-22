# qr-encode

QR Code encoder written in Zig.

## Usage

```
$ qr-encode --error M "Hello world"
```

![QR Code](./demo.png)

## Options

```
$ qr-encode --help

Usage: qr-encode [options] <message>

QR Code options:
  -e, --error     Error correction level       ["L", "M", "Q", "H"]

Options:
  -h, --help      Show help

Examples:
  qr-encode "some text"
  qr-encode -e H "some text"
```

## Requirements

- Zig 0.12+

## Installation

```bash
$ zig build-exe qr-encode.zig
$ ./qr-encode "Hello world"
```

## References

- [ISO/IEC 18004:2015 QR Code bar code symbology specification](https://www.iso.org/standard/62021.html)
- [Reed-Solomon codes for coders](https://en.wikiversity.org/wiki/Reed%E2%80%93Solomon_codes_for_coders)
- [node-qrcode](https://github.com/soldair/node-qrcode)

## License

[MIT](./LICENSE.md)

The word "QR Code" is registered trademark of:
DENSO WAVE INCORPORATED

