#! /bin/bash

usage() { echo $1; echo ;echo "Usage: ${0: -6} [-o dump.output] [-t Time] [-a N] [-r ] in.lammps " 1>&2; 
echo "Type: ${0: -6} -h for help" 1>&2; exit 1; }

# inizialise variables
path_to_this_file=$( realpath "$0"  ) && dirname "$path_to_this_file"}
path_to_this_file=${path_to_this_file%/*}
ovito=false
time_value=50
num_atoms=5
rand=0
help=false

# remove previous dump file whit same name to avoid errors
rm dump.* 2> /dev/null
rm log.* 2> /dev/null
rm ${path_to_this_file}/output/dump.* 2> /dev/null
rm ${path_to_this_file}/output/log.* 2> /dev/null

while getopts ":o:t:a:rh" opt; do
    case "${opt}" in
    
        o)  ovito=true
            dump=${OPTARG}
            [[ $dump == *"dump."* ]] || usage "Error: dump file needed"
            ;;

        t)  time_value=${OPTARG}
            [[ ! ${time_value//[0-9]/} ]] || usage "Error: unexpeted value for option '$opt': integer needed"
            ;;

        a)  num_atoms=${OPTARG}
            [[ ! ${num_atoms//[0-9]/} ]] || usage "Error: unexpeted value for option '$opt': integer needed"
            ;;

        h)  help=true
            ;;            
            
        \?)  usage "Error: Invalid option"
            ;;
            
        : ) usage "Error: Option '$OPTARG' requires an argument" 
            ;;
    esac
done
# the variable OPTIND holds the number of options parsed by the last call to getopts. 
# it is common practice to call the shift command at the end of your processing loop 
# to remove options that have already been handled from $@.
shift $((OPTIND-1))

# display helping manual 
if $help
then
    cat $path_to_this_file/../resources/instructions.txt
    exit 0
fi

# abort command, too many arguments
if [ $# -gt 1 ]
then 
    usage "Error: Too many argumets given"
fi

# abort command, too few arguments
if [ -z "$1" ] 
then
    usage   "Error: Missing input file"
fi

# run lammps input script with apropriate symulation time and random seed
env OMP_NUM_THREADS=16 lmp -sf omp -in $1 -var time_value $time_value -var num_atoms $num_atoms

# to be on the safe side
sleep 1

# create a output directory if not exist
mkdir -p output

# move the output files to the correct directory
mv $dump ${path_to_this_file}/output/    2> /dev/null
mv dump.* ${path_to_this_file}/output/   2> /dev/null
mv log.* ${path_to_this_file}/output/    2> /dev/null

# run ovito on the dump file
if $ovito 
then
    setsid ovito ${path_to_this_file}/output/$dump
fi

exit 0
