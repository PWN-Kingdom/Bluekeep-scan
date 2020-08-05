ip=""
port="3389"

if [[ $1 == "-h" ]]
then
	echo "  -ip     sets scanned ip addresses"
	echo "  -p      sets ports for scanning by default 3389"
	echo -e "\n  PS:     You can specify ranges for ip only"
    echo -e "          The script requires a clear sequence of flags: ip, port\n"

	echo "  EXAMPLES:"
	echo "          ./bluekeep_scan.sh -ip 192.168.1.1"
	echo "          ./bluekeep_scan.sh -ip 192.168.1.* -p 666"
	echo "          ./bluekeep_scan.sh -ip 192.168.1.1-192.168.1.255 "
	exit 1
fi

shift
while [[ $1 != '-p' ]] && [ $1 ]
do
	ip+=$1" "
	shift
done

if [[ $1 == "-p" ]]
then
	port=""
	while [ $2 ]
	do
		port=$2" "
		shift
	done
fi

ALL=`msfconsole -q -x "use auxiliary/scanner/rdp/cve_2019_0708_bluekeep; set RPORT $port; set RHOSTS $ip; run; exit;"`

FAILED=`echo $ALL | grep "failed"`
if [[ $FAILED != "" ]]
then
    echo "Error, check ip and port."
    exit 0;
fi

ALL=`echo $ALL | egrep -o "\+.*([0-9]{1,3}[\.]){3}[0-9]{1,3}.*vulnerable" | tr " " "\n" | egrep -e "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`

function print_line()
{
	len=24
	echo -n "|      $1"
	n=`echo -n $1 | wc -m`
	while (( len-- > n ))
	do
		echo -n " "
	done

	len=17
	echo -n "|       $2"
	n=`echo -n $2 | wc -m`
	while (( len-- > n ))
	do
		echo -n " "
	done
	echo "|"
}

if [[ $ALL != "" ]]
then
    for IP in $ALL
    do
        echo " ------------------------------------------------------- "
        print_line $IP "CVE-2019-0708"

    done
    echo " ------------------------------------------------------- "
else
    echo "Nothing"
fi