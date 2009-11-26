use strict;
use warnings;
use Test::More;


BEGIN {
   eval "use DateTime::Format::Strptime";
   plan skip_all => 'DateTime::Format::Strptime required' if $@;
}

#
# DateMDY
#
my $class = 'HTML::FormHandler::Field::DateMDY';
use_ok($class);
my $field = $class->new( name => 'test_field', );
ok( defined $field, 'new() called for DateMDY' );
$field->_set_input('10/02/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->clear_result;
$field->_set_input('14/40/09');
$field->validate_field;
ok( $field->has_errors, 'Has error 1' );
is( $field->fif, '14/40/09', 'Correct value' );
$field->clear_result;
$field->_set_input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Has error 2' );
is( $field->fif, '02/29/2009', 'isa DateTime' );
$field->clear_result;
$field->_set_input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');
$field->clear_result;
$field->_set_input('07/07/09');
ok( $field->validated, 'No errors 3' );
$field->clear_result;
$field->_set_value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif from value ok');


#
# Date
#
$class = 'HTML::FormHandler::Field::Date';
use_ok($class);
$field = $class->new( name => 'test_field', format => "mm/dd/yy" );
ok( defined $field, 'new() called for DateMDY' );
$field->_set_input('02/10/2009');
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value->isa('DateTime'), 'isa DateTime' );
$field->clear_result;
$field->date_start('2009-10-01');
$field->_set_input('08/01/2009');
$field->validate_field;
ok( $field->has_errors, 'Date is too early' );
is( $field->fif, '08/01/2009', 'Correct value' );
$field->clear_date_start;
$field->clear_result;
$field->date_end('2010-01-01');
$field->_set_input('02/01/2010');
$field->validate_field;
ok( $field->has_errors, 'date is too late');
$field->_set_input('02/29/2009');
$field->validate_field;
ok( $field->has_errors, 'Not a valid date' );
is( $field->fif, '02/29/2009', 'isa DateTime' );
$field->clear_result;
$field->_set_input('12/31/2008');
$field->validate_field;
ok( $field->validated, 'No errors 2' );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif ok');
$field->clear_result;
$field->_set_value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%m/%d/%Y", 'fif ok' ), 'fif from value ok');
$field->format("%d-%m-%Y");
$field->_set_input('07-07-09');
ok( $field->validated, 'No errors 3' );
$field->clear_result;
$field->_set_value( DateTime->new( year => 2008, month => 12, day => 31 ) );
is( $field->fif, $field->value->strftime("%d-%m-%Y", 'fif ok' ), 'fif from value ok');


{
   package Test::Date;
   use HTML::FormHandler::Moose;
   extends 'HTML::FormHandler';
   with 'HTML::FormHandler::Render::Simple';

   has_field 'end_date' => ( type => 'Date' );
}

my $form = Test::Date->new;
ok( $form, 'form with date created' );
ok( $form->render_field('end_date'), 'date field renders' );

#
# DateTime
#
$class = 'HTML::FormHandler::Field::DateTime';
use_ok($class);
#$field = $class->new( name => 'test_field', format => "mm/dd/yy" );
$field = $class->new( name => 'test_field', field_list => [ year => 'Integer',
    month => 'Integer', day => 'Integer' ] );
ok( defined $field, 'new() called for DateTime' );
$field->_set_input({ month => 2, day => 10, year => 2009 });
$field->validate_field;
ok( $field->validated, 'No errors 1' );
ok( $field->value && $field->value->isa('DateTime'), 'isa DateTime' );
is( $field->value->ymd, '2009-02-10', 'correct DateTime' );

$field = $class->new( name => 'test_field', field_list => [ year => 'Integer',
    month => { type => 'Integer', range_start => 9, range_end => 12 }, day => 'Integer' ] );
ok( $field, 'field compiles and builds' );

$field->clear_result;
my $date_hash = { month => 5, day => 10, year => 2009 };
$field->_set_input($date_hash);
$field->validate_field;
ok( $field->has_errors, 'Date is wrong month' );
is( $field->fif, $date_hash, 'Correct value' );

$field->clear_result;
$date_hash = { month => 10, day => 32, year => 2009 };
$field->_set_input($date_hash);
$field->validate_field;
ok( $field->has_errors, 'Date is wrong month' );
like( $field->errors->[0], qr/Not a valid/, 'DateTime error message' );
is( $field->fif, $date_hash, 'Correct value' );

done_testing;
