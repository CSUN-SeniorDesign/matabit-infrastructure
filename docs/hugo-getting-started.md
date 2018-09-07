# How to get started
In order to run the Hugo, you will need the binary file. OSX has a package manager called Homebrew which simplifies the installation of Hugo. Windows also has a similar package manager called choco. On the Ubuntu side, it's recommended to install it via snap due to the outdated debian repo. On RHEL/Centos/Fedora you can use the copr package manager to install it. After installing the binary run `hugo version` to make sure it installed correctly with the latest version of V0.48.

To install Hugo on OSX run `brew install hugo` in the terminal

To install Hugo on Windows run `choco install hugo`

On Ubuntu run `sudo snap install hugo --channel=extended`

After verifying Hugo was installed, create the boilerplate for the blog using `hugo new site matabit-blog` and add it to the git repo. Replace *matabit-blog* with the name of your project.

### Adding themes
Hugo has a plethora of themes to choose from at their [theme gallery](https://themes.gohugo.io/). In this project we selected [hyde-hyde](https://github.com/htr3n/hyde-hyde). Install the theme as a submodule using:

`git submodule add https://github.com/htr3n/hyde-hyde.git themes/hyde-hyde`

****Note on a freshly cloned project you must init and update the submodule, do this inside the theme/hyde-hyde directory using the command: `git submodule init; git submodule update`**

The next step is to configure the `config.toml` file accordingly. More info on the hyde-hyde [git repo](https://github.com/htr3n/hyde-hyde) or take a look at our own [toml](https://github.com/CSUN-SeniorDesign/matabit-blog/blob/master/config.toml) file
