const std = @import("std");

const tcp = @import("tcp.zig");

const logging = @import("logging.zig");

const IPv4Header = struct {
    version_ihl: u8,
    dscp_ecn: u8,
    total_length: u16,
    identification: u16,
    flags_fragment_offset: u16,
    ttl: u8,
    protocol: u8,
    header_checksum: u16,
    src_ip: [4]u8,
    dst_ip: [4]u8,
};

pub fn handleInet(packet: []u8) void {
    const pk = IPv4Header{
        .version_ihl = packet[0],
        .dscp_ecn = packet[1],
        .total_length = std.mem.readInt(u16, packet[2..4], .big),
        .identification = std.mem.readInt(u16, packet[4..6], .big),
        .flags_fragment_offset = std.mem.readInt(u16, packet[6..8], .big),
        .ttl = packet[8],
        .protocol = packet[9],
        .header_checksum = std.mem.readInt(u16, packet[10..12], .big),
        .src_ip = packet[12..16].*,
        .dst_ip = packet[16..20].*,
    };

    // Casting things for the IHL so to determine where the TCP starts:

    const ihl_words: u8 = pk.version_ihl & 0x0F;
    const ihl_bytes: usize = @as(usize, @intCast(ihl_words)) * 4;

    const protocol_name = switch (pk.protocol) {
        6 => "TCP",
        17 => "UDP",
        else => "Unknown",
    };

    const src_port = tcp.getSourcePort(packet[ihl_bytes..]);
    const dst_port = tcp.getDestinationPort(packet[ihl_bytes..]);

    std.debug.print("IPv4 - {s} - Source: {d}.{d}.{d}.{d}:{d}, Destination: {d}.{d}.{d}.{d}:{d}\n", .{ protocol_name, pk.src_ip[0], pk.src_ip[1], pk.src_ip[2], pk.src_ip[3], src_port, pk.dst_ip[0], pk.dst_ip[1], pk.dst_ip[2], pk.dst_ip[3], dst_port });

    if (logging.saveIPv4(protocol_name, pk.src_ip, src_port, pk.dst_ip, dst_port)) |_| {} else |_| {}
}
