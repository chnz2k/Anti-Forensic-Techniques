@echo off
for %i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do @%i: 2>nul && echo "processing %i" && cipher.exe /w:%i\ <nul
