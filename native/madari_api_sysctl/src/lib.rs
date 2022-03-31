extern crate libc;
extern crate sysctl;

use sysctl::Sysctl;

#[derive(Debug)]
#[repr(C)]
struct TimeVal {
    sec: libc::c_long,
    usec: libc::c_long, 
}

#[rustler::nif]
fn read(oid: String) -> std::string::String {
    let ctl = sysctl::Ctl::new(&oid).unwrap();
    ctl.value_string().unwrap()
}

#[rustler::nif]
fn boottime() -> std::string::String {
    let ctl = sysctl::Ctl::new("kern.boottime").unwrap();
    let val_enum = ctl.value().unwrap();
    if let sysctl::CtlValue::Struct(val) = val_enum {
        assert_eq!(std::mem::size_of::<TimeVal>(), val.len());
        let val_ptr: *const u8 = val.as_ptr();
        let struct_ptr: *const TimeVal = val_ptr as *const TimeVal;
        let struct_ref: &TimeVal = unsafe { &*struct_ptr };
        format!("{:?}", struct_ref.sec)
    }
    else {
        ctl.value_string().unwrap()
    }
}

rustler::init!("Elixir.Madari.Api.Sysctl", [read, boottime]);
