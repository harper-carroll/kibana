package main

import (
	"bufio"
	"flag"
	"fmt"
	"regexp"
	// "io"
	"os"
	"path"
	"strings"
)

func getImportPathFromDest(dest string) string {
	dest = strings.TrimSpace(dest) //remove all leading and trailing whitespace
	//split on github src path
	anchor := "/src/"
	r := strings.Split(dest, anchor)

	if len(r) <= 1 {
		fmt.Println("Failed to find src directory in dest path.")
		fmt.Println("Destination needs to be in your gopath to work!")
		os.Exit(-2)
	}
	fullPath := path.Clean(r[1]) //remove any funky ./... or extra // paths
	//auto fixes root/something/../woo to /root/woo
	dir, _ := path.Split(fullPath)
	fmt.Println(dir)
	return dir
}

func CopyFileWithNewImport(source string, dest string, conf Conf) (err error) {
	importPath := getImportPathFromDest(dest)
	packageLine := regexp.MustCompile(conf.Regex)
	importLine := regexp.MustCompile(`import\s{0,4}\"(.*)\"`)
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
		//replace import lines
		if importLine.MatchString(scanner.Text()) {
			matches := importLine.FindStringSubmatch(scanner.Text())
			path := "import \"" + importPath + strings.TrimSpace(matches[1]) + "\";"
			if len(matches) >= 2 {
				fmt.Fprintln(writer, path)
			}
		} else {
			//append after package name
			fmt.Fprintln(writer, scanner.Text())
			if packageLine.MatchString(scanner.Text()) {
				writer.WriteString(conf.Text)
			}
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

var confPath = flag.String("conf", "../scripts/rewriteProto/c.yml", "../scripts/rewriteProto/c.yml")

func main() {
	flag.Parse() // get the source and destination directory
	fmt.Println(*confPath)
	conf, err := GetConf(*confPath)
	if nil != err {
		fmt.Println(err)
		os.Exit(1)
	}
	fmt.Println(conf)
	sourceDir := flag.Arg(0) // get the source directory from 1st argument

	destDir := flag.Arg(1) // get the destination directory from the 2nd argument

	if len(sourceDir) <= 0 {
		fmt.Println("No source directory given")
		os.Exit(1)
	}

	if len(destDir) <= 0 {
		fmt.Println("No destination directory given")
		os.Exit(1)
	}

	fmt.Println("Source :" + sourceDir)

	// check if the source dir exist
	src, err := os.Stat(sourceDir)
	if err != nil {
		panic(err)
	}

	if !src.IsDir() {
		fmt.Println("Source is not a directory")
		os.Exit(1)
	}

	// create the destination directory
	fmt.Println("Destination :" + destDir)

	_, err = os.Open(destDir)

	err = CopyDir(sourceDir, destDir, conf)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println("Directory copied")
	}

}

