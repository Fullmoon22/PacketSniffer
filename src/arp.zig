const std = @import("std");

const logging = @import("logging.zig");

const ARPPacket = struct {
    htype: u16, // Hardware type (1 for Ethernet)
    ptype: u16, // Protocol type (0x0800 for IPv4)
    hlen: u8, // Hardware address length (6 for MAC)
    plen: u8, // Protocol address length (4 for IPv4)
    oper: u16, // Operation (1 for request, 2 for reply)
    sha: [6]u8, // Sender hardware address (MAC)
    spa: [4]u8, // Sender protocol address (IPv4)
    tha: [6]u8, // Target hardware address (MAC)
    tpa: [4]u8, // Target protocol address (IPv4)
};

pub fn handleARP(packet: []u8) void {
    const pk = ARPPacket{
        .htype = std.mem.readInt(u16, packet[0..2], .big),
        .ptype = std.mem.readInt(u16, packet[2..4], .big),
        .hlen = packet[4],
        .plen = packet[5],
        .oper = std.mem.readInt(u16, packet[6..8], .big),
        .sha = packet[8..14].*,
        .spa = packet[14..18].*,
        .tha = packet[18..24].*,
        .tpa = packet[24..28].*,
    };

    if (pk.oper == 1) {
        std.debug.print("ARP Request: Hardware type {d}, Protocol Type {d}, Operation {d}, Sender MAC: {x}:{x}:{x}:{x}:{x}:{x}, Sender IP: {d}.{d}.{d}.{d}, Target MAC: {x}:{x}:{x}:{x}:{x}:{x}, Target IP: {d}.{d}.{d}.{d}\n", .{ pk.htype, pk.ptype, pk.oper, pk.sha[0], pk.sha[1], pk.sha[2], pk.sha[3], pk.sha[4], pk.sha[5], pk.spa[0], pk.spa[1], pk.spa[2], pk.spa[3], pk.tha[0], pk.tha[1], pk.tha[2], pk.tha[3], pk.tha[4], pk.tha[5], pk.tpa[0], pk.tpa[1], pk.tpa[2], pk.tpa[3] });
    } else if (pk.oper == 2) {
        std.debug.print("ARP Reply: Hardware type {d}, Protocol Type {d}, Operation {d}, Sender MAC: {x}:{x}:{x}:{x}:{x}:{x}, Sender IP: {d}.{d}.{d}.{d}, Target MAC: {x}:{x}:{x}:{x}:{x}:{x}, Target IP: {d}.{d}.{d}.{d}\n", .{ pk.htype, pk.ptype, pk.oper, pk.sha[0], pk.sha[1], pk.sha[2], pk.sha[3], pk.sha[4], pk.sha[5], pk.spa[0], pk.spa[1], pk.spa[2], pk.spa[3], pk.tha[0], pk.tha[1], pk.tha[2], pk.tha[3], pk.tha[4], pk.tha[5], pk.tpa[0], pk.tpa[1], pk.tpa[2], pk.tpa[3] });
    }

    if (logging.saveARP(pk.htype, pk.ptype, pk.oper, pk.sha, pk.spa, pk.tha, pk.tpa)) |_| {} else |_| {}
}
