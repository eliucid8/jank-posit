# Set the paths to your source files and testbench file
$FILELIST = "filelist.txt"
# $TESTBENCH_FILE = "path/to/testbench/file.v"

# Set the name of the output file
$OUTPUT_FILE = "posit.vvp"

# Compile the source files and testbench file
& iverilog -o $OUTPUT_FILE -c $FILELIST -Wimplicit

# Run the compiled output file
& vvp $OUTPUT_FILE
