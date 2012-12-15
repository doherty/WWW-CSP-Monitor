package WWW::CSP::Receive;
use strict;
use warnings;

# ABSTRACT: receive Content Security Policy violation reports
# VERSION

use Dancer ':syntax';
use Dancer::Plugin::DBIC 'schema';
use Try::Tiny;

post '/' => sub {
    try {
        my $new_report = schema->resultset('Report')->create_FROM_JSON(
            ip   => request->address,
            json => param('csp-report'),
        );
        return { success => 1, report_id => $new_report->id };
    }
    catch {
        error $_;
        send_error({ error => $_ });
    };
};

get '/:report_id' => sub {
    my $report = schema->resultset('Report')->find({ report_id => param('report_id') });
    return $report || send_error({ error => 'notfound' });
};

true;
