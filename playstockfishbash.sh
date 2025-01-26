rm sf.out
mkfifo sf.out
rm stockfishbashinput.tmp
touch stockfishbashinput.tmp

./stockfishbash.sh $1 $2 $3 $4 < sf.out | ./stockfish > sf.out
