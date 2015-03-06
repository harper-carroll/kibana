package main

import (
	"gopkg.in/yaml.v2"
	"io/ioutil"
)

type Conf struct {
	Regex   string   `yaml:"regex"`
	Text    string   `yaml:"text"`
	Exclude []string `yaml:"exclude"`
}

func GetConf(path string) (c Conf, err error) {
	data, err := ioutil.ReadFile(path)
	if nil != err {
		return c, err
	}
	err = yaml.Unmarshal([]byte(data), &c)
	return c, err
}
