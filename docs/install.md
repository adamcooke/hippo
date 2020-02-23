# Installing

Hippo is a Ruby application and is distributed as a gem. You'll need Ruby 2.5 or higher and RubyGems installed on your computer. You only need to install Hippo on your local computer (the same place that you have `kubectl` installed).

## Verifying your dependencies

Check that you've got Ruby installed and it's the correct version:

```bash
ruby -v
# ruby 2.6.5p114 (2019-10-01 revision 67812) [x86_64-darwin19]
```

## Installing the gem

Just install the gem by entering the command below. Note the `-cli` at the end of the gem name.

```bash
gem install hippo-cli
# Fetching hippo-cli-1.2.1.gem
# Successfully installed hippo-cli-1.2.1
# 1 gem installed
```

## Checking your installation

Just check that everything has been installed correctly.

```bash
hippo version
# Hippo v1.2.1
```
