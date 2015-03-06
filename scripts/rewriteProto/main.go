package main

import (
	"bufio"
	"flag"
	"fmt"
	"regexp"
	// "io"
	"os"
	"strings"
)

func CopyFileWithNewImport(source string, dest string, conf Conf) (err error) {
	packageLine := regexp.MustCompile(conf.Regex)
	sourcefile, err := os.Open(source)
	if err != nil {
		return err
	}

	defer sourcefile.Close()
	os.Remove(dest) // ignore error but delete file if it already existed
	destfile, err := os.Create(dest)
	if err != nil {
		return err
	}

	defer destfile.Close()

	scanner := bufio.NewScanner(sourcefile)
	scanner.Split(bufio.ScanLines)
	writer := bufio.NewWriter(destfile)
	defer writer.Flush()
	for scanner.Scan() {
		// destfile.WriteString(scanner.Text())
		fmt.Fprintln(writer, scanner.Text())
		if packageLine.MatchString(scanner.Text()) {
			writer.WriteString(conf.Text)
		}
	}

	return err
}

func CopyDir(source string, dest string, conf Conf) (err error) {

	// get properties of source dir
	sourceinfo, err := os.Stat(source)
	if err != nil {
		return err
	}

	// create dest dir

	err = os.MkdirAll(dest, sourceinfo.Mode())
	if err != nil {
		return err
	}

	directory, _ := os.Open(source)

	objects, err := directory.Readdir(-1)

loop:
	for _, obj := range objects {

		sourcefilepointer := source + "/" + obj.Name()

		destinationfilepointer := dest + "/" + obj.Name()

		if obj.IsDir() {
			// create sub-directories - recursively
			err = CopyDir(sourcefilepointer, destinationfilepointer, conf)
			if err != nil {
				fmt.Println(err)
			}
		} else {
			for _, exclude := range conf.Exclude {
				if strings.Contains(sourcefilepointer, exclude) {
					fmt.Println("Excluding: ", sourcefilepointer)
					continue loop
				}
			}
			// perform copy
			err = CopyFileWithNewImport(sourcefilepointer, destinationfilepointer, conf)
			if err != nil {
				fmt.Println(err)
			}
		}

	}
	return
}

var confPath = flag.String("conf", "../scripts/RewriteProto/c.yml", "../scripts/RewriteProto/c.yml")

func main() {
	flag.Parse() // get the source and destination directory
	fmt.Println(*confPath)
	conf, err := GetConf(*confPath)
	if nil != err {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Println(conf)
	source_dir := flag.Arg(0) // get the source directory from 1st argument

	dest_dir := flag.Arg(1) // get the destination directory from the 2nd argument

	if len(source_dir) <= 0 {
		fmt.Println("No source directory given")
		os.Exit(1)
	}

	if len(dest_dir) <= 0 {
		fmt.Println("No destination directory given")
		os.Exit(1)
	}

	fmt.Println("Source :" + source_dir)

	// check if the source dir exist
	src, err := os.Stat(source_dir)
	if err != nil {
		panic(err)
	}

	if !src.IsDir() {
		fmt.Println("Source is not a directory")
		os.Exit(1)
	}

	// create the destination directory
	fmt.Println("Destination :" + dest_dir)

	_, err = os.Open(dest_dir)

	err = CopyDir(source_dir, dest_dir, conf)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Directory copied")
	}

}
