use Test::More tests => 4;
use strict;
use warnings;

# the order is important
use WWW::CSP::Receive;
use Dancer::Plugin::DBIC;
use JSON qw( decode_json );
use Dancer::Test;

schema->deploy;

route_exists [POST => '/csp'], 'a route handler is defined for POST /csp';
my $json = do { local $/; <DATA> };
my $payload = decode_json($json);

my $response = dancer_response( POST => '/csp', { params => $payload } );
is $response->{status}, 200, 'POSTed a report';
is_deeply decode_json($response->{content}), { success => 1, report_id => 1 }, 'POST claims success';

my $get = dancer_response( GET => '/1' );
is_deeply decode_json($get->{content}), $payload, 'report can be retrieved'
    or diag explain { response => $get, logs => read_logs };

__DATA__
{
  "csp-report": {
    "document-uri": "http://example.org/page.html",
    "referrer": "http://evil.example.com/",
    "blocked-uri": "http://evil.example.com/evil.js",
    "violated-directive": "script-src 'self' https://apis.google.com",
    "original-policy": "script-src 'self' https://apis.google.com; report-uri http://example.org/my_amazing_csp_report_parser"
  }
}
