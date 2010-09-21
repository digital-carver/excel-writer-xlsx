package TestFunctions;

###############################################################################
#
# TestFunctions - Helper functions for Excel::XLSX::Writer test cases.
#
# reverse('�'), September 2010, John McNamara, jmcnamara@cpan.org
#

use 5.010000;
use Exporter;
use strict;
use warnings;
use Test::More;
use Excel::XLSX::Writer;
use XML::Writer;


our @ISA       = qw(Exporter);
our @EXPORT    = ();
our @EXPORT_OK = qw(
  _expected_to_aref
  _got_to_aref
  _is_deep_diff
  _new_worksheet
  _new_workbook
);

our %EXPORT_TAGS = ();

our $VERSION = '0.01';


###############################################################################
#
# Turn the embedded XML in the __DATA__ section of the calling test program
# into an array ref for comparison testing. Also does some data formatting
# to make comparison easier.
#
sub _expected_to_aref {

    my @data;

    while ( <main::DATA> ) {
        next unless /\S/;
        chomp;
        s{/>$}{ />};
        s{^\s+}{};
        push @data, $_;
    }

    return \@data;
}


###############################################################################
#
# Convert an XML string into an array ref for comparison testing.
#
sub _got_to_aref {

    my $xml_str = shift;

    $xml_str =~ s/\n//g;

    # Split the XML into chunks at element boundaries.
    my @data = split /(?<=>)(?=<)/, $xml_str;

    return \@data;
}


###############################################################################
#
# Use Test::Differences:: eq_or_diff() where available or else fall back to
# using Test::More::is_deeply().
#
sub _is_deep_diff {
    my ( $got, $expected, $caption, ) = @_;

    eval {
        require Test::Differences;
        Test::Differences->import();
    };

    if ( !$@ ) {
        eq_or_diff( $got, $expected, $caption, { context => 1 } );
    }
    else {
        is_deeply( $got, $expected, $caption );
    }

}


###############################################################################
#
# Create a new Worksheet object and bind the output to the supplied scalar ref.
#
sub _new_worksheet {

    my $got_ref = shift;

    open my $got_fh, '>', $got_ref or die "Failed to open filehandle: $!";

    my $worksheet = new Excel::XLSX::Writer::Worksheet;
    my $writer = new XML::Writer( OUTPUT => $got_fh );

    $worksheet->{_writer} = $writer;

    return $worksheet;
}


###############################################################################
#
# Create a new Workbook object and bind the output to the supplied scalar ref.
#
sub _new_workbook {

    my $got_ref = shift;

    open my $got_fh, '>', $got_ref or die "Failed to open filehandle: $!";
    open my $tmp_fh, '>', \my $tmp or die "Failed to open filehandle: $!";

    my $workbook = Excel::XLSX::Writer->new( $tmp_fh );
    my $writer = new XML::Writer( OUTPUT => $got_fh );

    $workbook->{_writer} = $writer;

    return $workbook;
}


1;


__END__
