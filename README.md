# Log::File

Log::File provides very basic application logging for applications.

## USAGE

```
use Log::File;

my $log = Log::File->new( {file => $filename} );

$log->debug("This is a debug message");
$log->info("This is an informational message");
$log->notice("This is a notice message");
$log->warn("This is a warining message");
$log->die("This is a message from the dead");

# Full debug logging
$log->level(5);

# Log only error and critical messages
$log->level(1);
```

## INSTALL

To install this module, run the following commands:

```
  perl Makefile.PL
  make
  make test
  make install
```

## DEPENDENCIES

* Carp
* Class::InsideOut
* Fcntl
* IO::File
* Readonly

Copyright (C) 2014, Trevor S. Cornpropst
