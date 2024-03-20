module BusTicket::ticket {

    // === Imports ===

    // use std::string::{Self,String};
    // use std::vector;
    // use std::debug;

    // use sui::transfer;
    // use sui::object::{Self,UID,ID};
    // use sui::url::{Self,Url};
    // use sui::coin::{Self, Coin, CoinMetadata};
    // use sui::sui::SUI;
    // use sui::object_table::{Self,ObjectTable};
    // use sui::event;
    // use sui::tx_context::{Self,TxContext};
    // use sui::vec_set::{Self, VecSet};
    // use sui::table::{Self, Table};
    // use sui::balance:: {Self, Balance};
    // use sui::bag::{Self,Bag};

    // === Friends ===

    // =================== Errors ===================

    // === Constants ===

    // === Structs ===

    //share object that we keep ticket price 
    struct Station has key {

    }

    struct Bus has key, store {

    }

    struct Ticket has store, copy, drop {

    }

    struct AdminCap has key {

    }

    // =================== Events ===================

    struct BusCreated has copy, drop {

    }


    // =================== Initializer ===================    

    fun init() {

    }

    // === Public-Mutative Functions ===

    // owner of station should create new bus 
    public fun new() {

    }

    // Users can buy tickets
    public fun buy() {

    }
    // Users can rebate tickets before an hour 
    public fun rebate() {

    }

    // return the available tickets from bus 
    public fun get_tickets() {

    }

  







 

    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Friend Functions ===

    // === Private Functions ===

    // === Test Functions ===





































}