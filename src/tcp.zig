const std = @import("std");

const TCPHeader = struct {
    src_port: u16,
    dst_port: u16,
    seq_number: u32,
    ack_number: u32,
    data_offset_reserved_flags: u16,
    window_size: u16,
    checksum: u16,
    urgent_pointer: u16,
};

pub fn handleTCP(packet: []u8) void {
    if (packet.len < 20) {
        return 0;
    }

    const pk = TCPHeader{
        .src_port = std.mem.readInt(u16, packet[0..2], .big),
        .dst_port = std.mem.readInt(u16, packet[2..4], .big),
        .seq_number = std.mem.readInt(u32, packet[4..8], .big),
        .ack_number = std.mem.readInt(u32, packet[8..12], .big),
        .data_offset_reserved_flags = std.mem.readInt(u16, packet[12..14], .big),
        .window_size = std.mem.readInt(u16, packet[14..16], .big),
        .checksum = std.mem.readInt(u16, packet[16..18], .big),
        .urgent_pointer = std.mem.readInt(u16, packet[18..20], .big),
    };

    std.debug.print("Source Port: {d}, Destination Port: {d}\n", .{ pk.src_port, pk.dst_port });
}

pub fn getSourcePort(packet: []u8) u16 {
    if (packet.len < 20) {
        return 0;
    }

    const pk = TCPHeader{
        .src_port = std.mem.readInt(u16, packet[0..2], .big),
        .dst_port = std.mem.readInt(u16, packet[2..4], .big),
        .seq_number = std.mem.readInt(u32, packet[4..8], .big),
        .ack_number = std.mem.readInt(u32, packet[8..12], .big),
        .data_offset_reserved_flags = std.mem.readInt(u16, packet[12..14], .big),
        .window_size = std.mem.readInt(u16, packet[14..16], .big),
        .checksum = std.mem.readInt(u16, packet[16..18], .big),
        .urgent_pointer = std.mem.readInt(u16, packet[18..20], .big),
    };

    return pk.src_port;
}

pub fn getDestinationPort(packet: []u8) u16 {
    if (packet.len < 20) {
        return 0;
    }
    const pk = TCPHeader{
        .src_port = std.mem.readInt(u16, packet[0..2], .big),
        .dst_port = std.mem.readInt(u16, packet[2..4], .big),
        .seq_number = std.mem.readInt(u32, packet[4..8], .big),
        .ack_number = std.mem.readInt(u32, packet[8..12], .big),
        .data_offset_reserved_flags = std.mem.readInt(u16, packet[12..14], .big),
        .window_size = std.mem.readInt(u16, packet[14..16], .big),
        .checksum = std.mem.readInt(u16, packet[16..18], .big),
        .urgent_pointer = std.mem.readInt(u16, packet[18..20], .big),
    };
    return pk.dst_port;
}
