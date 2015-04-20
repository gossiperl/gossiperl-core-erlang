%% Copyright (c) 2014 Radoslaw Gruchalski <radek@gruchalski.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.

-module(gossiperl_client_listener).

-export([ connected/2,
          disconnected/1,
          subscribed/3,
          unsubscribed/3,
          event/4,
          forward_ack/3,
          forward/4,
          failed/2 ]).

%%%=========================================================================
%%%  API
%%%=========================================================================

-type overlay_name() :: binary().
-type event_type() :: binary().
-type event_types() :: [ event_type() ].
-type heartbeat() :: non_neg_integer().
-type event_object() :: binary().
-type member_name() :: binary().
-type digest_type() :: binary().
-type digest_id() :: binary().

-export_type([ overlay_name/0,
               event_type/0,
               event_types/0,
               heartbeat/0,
               member_name/0,
               digest_type/0,
               digest_id/0 ]).

-callback connected( OverlayName :: overlay_name(), EventTypes :: event_types() ) -> ok.

-callback disconnected( OverlayName :: overlay_name() ) -> ok.

-callback subscribed( OverlayName :: overlay_name(), EventTypes :: event_types(), Heartbeat :: heartbeat() ) -> ok.

-callback unsubscribed( OverlayName :: overlay_name(), EventTypes :: event_types(), Heartbeat :: heartbeat() ) -> ok.

-callback event( OverlayName :: overlay_name(), EventType :: event_type(), EventObject :: event_object(), Heartbeat :: heartbeat() ) -> ok.

-callback forward_ack( OverlayName :: overlay_name(), MemberName :: member_name(), ReplyId :: digest_id() ) -> ok.

-callback forward( OverlayName :: overlay_name(), DigestType :: digest_type(), BinaryEnvelope :: binary(), EnvelopeId :: digest_id() ) -> ok.

-callback failed( OverlayName :: overlay_name(), Reason :: term() ) -> ok.

%%%=========================================================================
%%%  Implmeentation
%%%=========================================================================

%% @doc Client connected to overlay with event types.
-spec connected( OverlayName :: overlay_name(), EventTypes :: event_types() ) -> ok.
connected( OverlayName, EventTypes ) ->
  gossiperl_log:info("[~p] Connected with ~p.", [ OverlayName, EventTypes ]).

%% @doc Client disconnected from overlay.
-spec disconnected( OverlayName :: overlay_name() ) -> ok.
disconnected( OverlayName ) ->
  gossiperl_log:info("[~p] Disconnected.", [ OverlayName ]).

%% @doc Overlay confirmed subscribing to event types.
-spec subscribed( OverlayName :: overlay_name(), EventTypes :: event_types(), Heartbeat :: heartbeat() ) -> ok.
subscribed( OverlayName, EventTypes, _Heartbeat ) ->
  gossiperl_log:info("[~p] Subscribed to ~p.", [ OverlayName, EventTypes ]).

%% @doc Overlay confirmed unsubscribing from event types.
-spec unsubscribed( OverlayName :: overlay_name(), EventTypes :: event_types(), Heartbeat :: heartbeat() ) -> ok.
unsubscribed( OverlayName, EventTypes, _Heartbeat ) ->
  gossiperl_log:info("[~p] Unsubscribed from ~p.", [ OverlayName, EventTypes ]).

%% @doc An overlay member event (member_in, member_out and so on).
-spec event( OverlayName :: overlay_name(), EventType :: event_type(), EventObject :: event_object(), Heartbeat :: heartbeat() ) -> ok.
event( OverlayName, EventType, EventObject, _Heartbeat ) ->
  gossiperl_log:info("[~p] Received event ~p from ~p.", [ OverlayName, EventType, EventObject ]).

%% @doc Forward message acknowledgement from an overlay.
-spec forward_ack( OverlayName :: overlay_name(), MemberName :: member_name(), ReplyId :: digest_id() ) -> ok.
forward_ack( OverlayName, MemberName, ReplyId ) ->
  gossiperl_log:info("[~p] Received forward ack from ~p with ID ~p.", [ OverlayName, MemberName, ReplyId ]).

%% @doc Forward a message to an overlay.
-spec forward( OverlayName :: overlay_name(), DigestType :: digest_type(), BinaryEnvelope :: binary(), EnvelopeId :: digest_id() ) -> ok.
forward( OverlayName, DigestType, BinaryEnvelope, EnvelopeId ) ->
  gossiperl_log:info("[~p] Received forwarded message of type with ID ~p. Envelope byte size is: ~p", [ OverlayName, DigestType, EnvelopeId, byte_size( BinaryEnvelope ) ]).

%% @doc There was an error while processing data. Check Reason.
-spec failed( OverlayName :: overlay_name(), Reason :: term() ) -> ok.
failed( OverlayName, Reason ) ->
  gossiperl_log:err("[~p] Received an error: ~p", [ OverlayName, Reason ]).
