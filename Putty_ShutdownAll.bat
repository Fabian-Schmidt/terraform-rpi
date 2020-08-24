@ECHO OFF
echo Raspi4-01
plink -batch -ssh pi@192.168.10.22 -i ssh.ppk sudo nohup sh -c 'sleep 2; shutdown -r now' &
echo Raspi3-01
plink -batch -ssh pi@192.168.10.21 -i ssh.ppk sudo nohup sh -c 'sleep 2; shutdown -r now' &
echo Raspi2-01
plink -batch -ssh pi@192.168.10.20 -i ssh.ppk sudo nohup sh -c 'sleep 2; shutdown -r now' &
echo OpenWrt-Slate
plink -batch -ssh root@192.168.10.1 -i ssh.ppk sh -c 'sleep 2; halt' &
pause