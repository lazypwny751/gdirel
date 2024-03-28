# GDIREL
Get distribution information, like lsb_release

## Description.
Low requirements utility tool that provides basic information about distribution, is like lsb_release.

## Installation.
```sh
git clone https://github.com/lazypwny751/gdirel.git && cd "gdirel"
sudo make all && sudo make clean
```

## Usage.
```
gdirel.sh usage:
	-k	print current kernel release.
	-o	print distribution name.
	-m	print current/native package manager name.
	-n	how many packages are installed with current/native package manager.
	-p	print processor model.
	-c	print the cpu have how many cores.
	-a	print all informations above.
	-v	print with verbose "add header like (any: x)".
	-h	print this screen.
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GPL3](https://choosealicense.com/licenses/gpl-3.0/)