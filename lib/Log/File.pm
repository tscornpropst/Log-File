package Log::File;

use strict;
use warnings;
use utf8;

our $VERSION = '0.04';

use Carp;
use Class::InsideOut qw(:std);
use Fcntl ':flock';
use IO::File;
use Readonly;

Readonly::Scalar my $DEFAULT_PERM => oct(644);
Readonly::Scalar my $DEFAULT_MODE => O_WRONLY | O_TRUNC | O_CREAT;
Readonly::Scalar my $DEBUG        => 5;
Readonly::Scalar my $INFO         => 4;
Readonly::Scalar my $NOTICE       => 3;
Readonly::Scalar my $WARNING      => 2;
Readonly::Scalar my $CRITICAL     => 1;
Readonly::Scalar my $ERROR        => 1;

private append => my %append;
private fh     => my %fh;
private mode   => my %mode;
private file   => my %file;
private perms  => my %perms;
private level  => my %level;

#-------------------------------------------------------------------------------
sub new {
    my ( $class, $arg ) = @_;

    my $self = register($class);

    $file{id $self} = $arg->{file}
        ## no critic qw(ProhibitMagicNumbers) false positive
        or croak 'Missing file parameter in ', ( caller(0) )[3];
        # critic

    $perms  {id $self} = $arg->{perms}  || $DEFAULT_PERM;
    $append {id $self} = $arg->{append} || 0;
    $mode   {id $self} =
        $arg->{append}
        ? O_WRONLY | O_APPEND | O_CREAT
        : $DEFAULT_MODE;

    $level{id $self} = $arg->{level} || $DEBUG;

    $fh{id $self}
        = IO::File->new( $file{id $self}, $mode{id $self}, $perms{id $self},
        )
        or croak "Could not create file $arg->{file} in ",
        ## no critic qw(ProhibitMagicNumbers) false positive
        ( caller(0) )[3], '. Check file ownership and permissions.';
        # critic

    $fh{id $self}->autoflush(1);

    # Force permissions for existing files
    ## no critic qw(ProhibitMagicNumbers) false positive
    croak "Could not set permissions on $file{id $self} in ", ( caller(0) )[3]
    # critic
        unless chmod( $perms{id $self}, $file{id $self} );

    return $self;
}

#-------------------------------------------------------------------------------
sub DEMOLISH {
    my ($self) = @_;

    $fh{id $self}->close() if ( $fh{id $self} );

    return;
}

#-------------------------------------------------------------------------------
sub close {
    my ($self) = @_;

    return $fh{id $self}->close();
}

#-------------------------------------------------------------------------------
sub _log {
    my ( $self, $msg ) = @_;

    if ( $msg =~ /\[debug|warning\]/msx ) { print {*STDERR} $msg; }

    flock( $fh{id $self}, LOCK_EX );

    $fh{id $self}->print($msg);

    flock( $fh{id $self}, LOCK_UN );

    return 1;
}

#-------------------------------------------------------------------------------
sub _msg {
    my ( $priority, $msg ) = @_;
    my $time = localtime;

    chomp $msg;

    return "$time [$priority] $msg\n";
}

#-------------------------------------------------------------------------------
sub debug {
    my ( $self, $string ) = @_;

    return unless $DEBUG <= $level{id $self};
    return _log( $self, _msg( 'debug', $string ) );
}

#-------------------------------------------------------------------------------
sub error {
    my ( $self, $string ) = @_;
    return _log( $self, _msg( 'error', $string ) );
}

#-------------------------------------------------------------------------------
sub info {
    my ( $self, $string ) = @_;

    return unless $INFO <= $level{id $self};
    return _log( $self, _msg( 'info', $string ) );
}

#-------------------------------------------------------------------------------
sub notice {
    my ( $self, $string ) = @_;

    return unless $NOTICE <= $level{id $self};
    return _log( $self, _msg( 'notice', $string ) );
}

#-------------------------------------------------------------------------------
sub warn {
    my ( $self, $string ) = @_;

    return unless $WARNING <= $level{id $self};

    carp $string;

    return _log( $self, _msg( 'warning', $string ) );
}

#-------------------------------------------------------------------------------
sub die {
    my ( $self, $string ) = @_;

    _log( $self, _msg( 'critical', $string ) );

    croak $string;
}

#-------------------------------------------------------------------------------
sub level {
    my ( $self, $priority ) = @_;
    $level{id $self} = $priority;
    return $level{id $self};
}

1;

__END__

=pod

=head1 NAME

Log::File - Object Oriented interface for application logging.

=head1 VERSION

This documentation refers to Log::File version 0.0.4.

=head1 SYNOPSIS

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

=head1 DESCRIPTION

B<Log::File> was inspired by Lincoln Stein's LogFile package in Network Programming with Perl. This module provides an easy to use log file interface with output similar to syslog but without all the overhead and dependencies of other logging packages.

Logfiles should be immutable so this object creates 'write only' files. This means there are no facilities for seeking, modifying or otherwise editing files, only output.

Logging defaults to level 4 or full logging. The log level may be reduced with the level method or set to a lower value in the constructor. Level 5 is the most verbose, level 1 is the least verbose logging only errors and critical messages.

This object's destructor takes care of closing the file handle.

=head1 SUBROUTINES/METHODS

=over

=item new()

The constructor takes up to four parameters 'file', 'perms', 'append', and 'priority'. The only required parameter is 'file'.

The 'file' parameter sets the name of the file for logging output. Specify the fully qualified path name here.

For example:

    my $log = Log::File->new( {file => '/var/log/mylogfile.log'} );

The 'perms' parameter is used to set permissions on the output file. File permissions default to 0644 (i.e. owner read/write, all others read only). You may explicitly set the permissions using the 'perms' parameter. You cannot use quotes for the file permissions or they will not be applied.

For example:

    # Works
    my $log = Log::File->new( {file => $filename, $perm => 0644} );

    # Doesn't work
    my $log = Log::File->new( {file => $filename, $perm => '0644'} );

File mode is set to write only, truncate, create by default. If you wish to append to a log file, set append to a true value.

For example:

    my $log = Log::File->new( {file => $filename, append => 1} );

The priority level for messages may be set in the constructor or after the object is created with the priority method.

For example:

    # Log messages only messages with a level of ERROR or CRITICAL
    my $log = Log::File->new( {file => $filename, level => 1} );

=item close()

Close the filehandle on the log file.

=item debug()

Logs messages with a priority of DEBUG. Debug messages are printed to the screen in addition to being written to the log file.

=item error()

Log messages with a priority of ERROR.

=item info()

Logs messages with a priority of INFO. This is the standard level of logging used for informational messages.

=item notice()
 
Logs messages with a priority of NOTICE.

=item warn()

Logs messages with a priority of WARNING.

=item die()

Logs messages with a priority of CRITICAL and dies with the message string.

=item level()

Sets the verbosity level for message logging. Default is DEBUG or 5, log everything. The message level constants are not exported. You have to specify the numeric value for the priority level. Only messages less than or equal to the set level are logged. Level values are:

    DEBUG     => 5      # Log everything
    INFO      => 4      # Standard messages
    NOTICE    => 3
    WARNING   => 2
    CRITICAL  => 1
    ERROR     => 1      # Errors are always logged

    Example:

    $log->level(2);     # Log warning, critical and error

=back

=head1 INTERNAL METHODS

=over

=item _msg()

Concatenates the log entry. Adds time stamp, log level, and message string. Calls _log() for writing.

=item _log()

Receives message string, locks log file for writing, writes message and unlocks file. This method also checks for debug and warning messages and prints them to STDERR.

=back

=head1 DIAGNOSTICS

=over

=item C<Missing %s parameter in %s>

You didn't say my $log = Log::File::->new( { file => './logfile.log' } )

=item C<Could not create file %s in %s>

There was an error creating the file. Check file permissions.

=item C<Could not set permissions on %s in %s>

There was a problem setting the permissions on the file.

=back

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 DEPENDENCIES

=over

=item * Carp

=item * Class::InsideOut

=item * Fcntl

=item * IO::File

=item * Readonly

=back

=head1 INCOMPATIBILITIES

None.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any issues or feature requests to Trevor S. Cornpropst tscornpropst@gmail.com. Patches are welcome.

=head1 AUTHOR

Trevor S. Cornpropst C<tscornpropst@gmail.com>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2005 - 2014, Trevor S. Cornpropst. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

