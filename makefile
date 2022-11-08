all:
	./crt-to-header.sh
	g++ main.cpp -o main -I. -lssl -lcrypto
