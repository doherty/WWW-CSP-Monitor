use strict;
use warnings;
use Module::Build 0.3601;
use File::Spec;

my $mb_subclass = Module::Build->subclass(
    class => 'Module::Build::Custom',
    code => <<'SUBCLASS');

sub ACTION_docs {
    my $self = shift;
    use File::Path qw(remove_tree);
    use File::Spec;
    $self->SUPER::ACTION_docs;
    remove_tree( File::Spec->catdir(qw/blib bindoc/) );
}
SUBCLASS


my $build = $mb_subclass->new(
    module_name => 'WWW::CSP::Monitor',
    dist_abstract => 'receive Content Security Policy violation reports',
    dist_author => 'Mike Doherty <doherty@cpan.org>',
##{ $plugin->get_prereqs ##},
    create_packlist => 0,
);

my $install_base = File::Spec->catdir(
    File::Spec->rootdir, qw{
        var
        www
        csp
    },
    ##{ $version ##}
);
$build->install_base( $install_base );
$build->install_path( script => $install_base );

$build->create_build_script;
