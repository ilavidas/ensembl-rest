#!/usr/bin/env perl
# Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# Copyright [2016-2018] EMBL-European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


#!/bin/env perl

use strict;
use warnings;
use Daemon::Control;
use FindBin qw($Bin);

my $root_dir   = $ENV{ENSEMBL_REST_ROOT} || "$Bin/../../";
my $psgi_file  = "$root_dir/configurations/production/ensrest.psgi";
my $starman    = $ENV{ENSEMBL_REST_STARMAN} || 'starman';
my $port       = $ENV{ENSEMBL_REST_PORT} || 5000;
my $workers    = $ENV{ENSEMBL_REST_WORKERS} || 10;
my $backlog    = $ENV{ENSEMBL_REST_BACKLOG} || 1024;
my $status_file= $ENV{ENSEMBL_REST_STATUS} || "$root_dir/ensembl_rest.status";
my $restart_interval = 1;
my $max_requests=$ENV{ENSEMBL_REST_MAX_REQUESTS} || 10000;
#my $access_log = "$root_dir/logs/access_log";
#my $error_log  = "$root_dir/logs/error_log";
my $pid_file   = $ENV{ENSEMBL_REST_PID} || "$root_dir/ensembl_rest.pid";
my $init_config= $ENV{ENSEMBL_INIT_CONFIG} || '~/.bashrc';

Daemon::Control->new(
  {
    name         => "Ensembl REST",
    lsb_start    => '$syslog $remote_fs',
    lsb_stop     => '$syslog',
    lsb_sdesc    => 'Ensembl REST server control',
    lsb_desc     => 'Ensembl REST server control',
    stop_signals => [ qw(QUIT TERM TERM INT KILL) ],
    init_config  => $init_config,
    program      => $starman,
    program_args => [ 
      '--backlog',    $backlog,
      '--listen',     ":$port", 
      '--workers',    $workers, 
      '--max-requests',$max_requests,
      '--status-file', $status_file,
      '--interval',   $restart_interval,
      $psgi_file 
    ],
    pid_file     => $pid_file,
  }
)->run;
