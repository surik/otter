%%%-------------------------------------------------------------------
%%% Licensed to the Apache Software Foundation (ASF) under one
%%% or more contributor license agreements.  See the NOTICE file
%%% distributed with this work for additional information
%%% regarding copyright ownership.  The ASF licenses this file
%%% to you under the Apache License, Version 2.0 (the
%%% "License"); you may not use this file except in compliance
%%% with the License.  You may obtain a copy of the License at
%%%
%%%   http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing,
%%% software distributed under the License is distributed on an
%%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%%% KIND, either express or implied.  See the License for the
%%% specific language governing permissions and limitations
%%% under the License.
%%%
%%% @doc
%%% This API uses the process dictionary to collect span information
%%% and can be used when all span tags an events happen in the same
%%% request handling process.
%%% @end
%%%-------------------------------------------------------------------

-module(otter_span_pdict_api).
-export([
         start/1, start/2, start/3,
         finish/0, finish/1,
         get_span/0,
         put_span/1,
         ids/0, ids/1,
         log/1, log/2,
         tag/2, tag/3
        ]).

-include_lib("otter_lib/src/otter.hrl").

-spec start(info()) -> span().
start(Name) ->
    Span = otter_lib_span:start(Name),
    put(otter_span_information, Span),
    Span.


-spec start(info(), trace_id()) -> span().
start(Name, TraceId) when is_integer(TraceId) ->
    Span = otter_lib_span:start(Name, TraceId),
    put(otter_span_information, Span),
    Span.

-spec start(info(), trace_id(), span_id()) -> span().
start(Name, TraceId, ParentId) when is_integer(TraceId), is_integer(ParentId) ->
    Span = otter_lib_span:start(Name, TraceId, ParentId),
    put(otter_span_information, Span),
    Span.

-spec tag(info(), info()) -> span().
tag(Key, Value) ->
    Span = otter_lib_span:tag(get(otter_span_information), Key, Value),
    put(otter_span_information, Span),
    Span.

-spec tag(info(), info(), service()) -> span().
tag(Key, Value, Service) ->
    Span = otter_lib_span:tag(get(otter_span_information), Key, Value, Service),
    put(otter_span_information, Span),
    Span.

-spec log(info()) -> span().
log(Text) ->
    Span = otter_lib_span:log(get(otter_span_information), Text),
    put(otter_span_information, Span),
    Span.


-spec log(info(), service()) -> span().
log(Text, Service) ->
    Span = otter_lib_span:log(get(otter_span_information), Text, Service),
    put(otter_span_information, Span),
    Span.

-spec finish() -> ok.
finish() ->
    otter_filter:span(otter_lib_span:finish(get(otter_span_information))).


-spec finish(span()) -> ok.
%% @doc This is provided purely for API compatibility with the otter_span_api module
finish(#span{} = _Span) ->
    finish().

-spec ids() -> {trace_id(), span_id()}.
ids() ->
    otter_lib_span:get_ids(get(otter_span_information)).

-spec ids(span()) -> {trace_id(), span_id()}.
%% @doc This is provided purely for API compatibility with the otter_span_api module
ids(#span{} = _Span) ->
    ids().

-spec get_span() -> span().
get_span() ->
    get(otter_span_information).

-spec put_span(span()) -> term().
put_span(Span) ->
    put(otter_span_information, Span).