package WordList::Color::Any;

# AUTHORITY
# DATE
# DIST
# VERSION

use parent qw(WordList);

use Role::Tiny::With;
with 'WordListRole::FirstNextResetFromEach';

use Sah::PSchema 'get_schema';

our $DYNAMIC = 1;

our %PARAMS = (
    scheme => {
        summary => 'Graphics::ColorNames scheme name, e.g. "WWW" '.
            'for Graphics::ColorNames::WWW',
        schema => get_schema('perl::modname', {ns_prefix=>'Graphics::ColorNames'}, {req=>1}),
        req => 1,
    },
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my $mod = "Graphics::ColorNames::$self->{params}{scheme}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    my $res = &{"$mod\::NamesRgbTable"}();
    $self->{_names} = [sort keys %$res];
    $self;
}

sub each_word {
    my ($self, $code) = @_;

    for (@{ $self->{_names} }) {
        no warnings 'numeric';
        my $ret = $code->($_);
        return if defined $ret && $ret == -2;
    }
}

1;
# ABSTRACT: Wordlist from any Graphics::ColorNames::* module

=head1 SYNOPSIS

 use WordList::Color::Any;

 my $wl = WordList::Color::Any->new(scheme => 'WWW');
 $wl->each_word(sub { ... });


=head1 DESCRIPTION

This is a dynamic, parameterized wordlist to get list of words from a
Graphics::ColorNames::* module.


=head1 SEE ALSO

L<WordList>

L<Graphics::ColorNames>
