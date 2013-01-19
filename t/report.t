use Test::More;
use strict;
use warnings;

# the order is important
use WWW::CSP::Receive;
use Dancer::Plugin::DBIC;
use JSON qw( decode_json );
use Dancer::Test;
use Try::Tiny;

schema->deploy;

route_exists [POST => '/'], 'a route handler is defined for POST /';

while ( my $json = <DATA> ) {
    my $payload = decode_json($json);
    my $response = dancer_response( POST => '/', { params => $payload } );
    is $response->{status}, 200, 'POSTed a report';
    is_deeply decode_json($response->{content})->{success} => 1, 'POST claims success'
        or diag explain $response->{content};
    my $report_id = decode_json($response->{content})->{report_id};

    my $get = dancer_response( GET => "/$report_id" );
    my $get_json = try { decode_json($get->{content}) };
    is_deeply $get_json, $payload, 'report can be retrieved'
        or diag explain { response => $get, logs => read_logs };
}
done_testing;
__DATA__
{"csp-report":{"document-uri":"http://hashbang.ca","referrer":"http://evil.attacker.com","blocked-uri":"http://evil.attacker.com/exfiltrate_browser_data.js","violated-directive":"script-src 'self' https://ajax.googleapis.com","original-policy":"script-src 'self' https://ajax.googleapis.com; report-uri http://hashbang.ca/csp"}}
{"csp-report":{"document-uri":"http://hashbang.ca/2012/06/09/on-studying-programming-and-programmers","referrer":"http://hashbang.ca/","violated-directive":"default-src 'self'","original-policy":"default-src 'self'; report-uri http://csp.hashbang.ca;","blocked-uri":""}}