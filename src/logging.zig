const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
pub fn createFiles() !void {
    const folder = std.fs.cwd();

    if (folder.access("IPv4.txt", .{ .mode = .write_only })) |_| {} else |_| {
        _ = try folder.createFile("IPv4.txt", .{});
    }

    if (folder.access("ARP.txt", .{ .mode = .write_only })) |_| {} else |_| {
        _ = try folder.createFile("ARP.txt", .{});
    }
}

pub fn saveIPv4(protocol: []const u8, src_ip: [4]u8, src_port: u16, dst_ip: [4]u8, dst_port: u16) !void {
    if (std.fmt.allocPrint(allocator, "IPv4 - {s} - Source: {d}.{d}.{d}.{d}:{d}, Destination: {d}.{d}.{d}.{d}:{d}\n", .{ protocol, src_ip[0], src_ip[1], src_ip[2], src_ip[3], src_port, dst_ip[0], dst_ip[1], dst_ip[2], dst_ip[3], dst_port })) |string| {
        defer allocator.free(string);
        const folder = std.fs.cwd();
        if (folder.openFile("IPv4.txt", .{ .mode = .read_write })) |file| {
            defer file.close();
            const end_pos = try file.getEndPos();
            _ = try file.pwrite(string, end_pos);
        } else |_| {
            return;
        }
    } else |_| {
        return;
    }
}

pub fn saveARP(hardware: u16, protocol: u16, operation: u16, sender_MAC: [6]u8, sender_ip: [4]u8, target_MAC: [6]u8, target_ip: [4]u8) !void {
    if (std.fmt.allocPrint(allocator, "ARP Request: Hardware type {d}, Protocol Type {d}, Operation {d}, Sender MAC: {x}:{x}:{x}:{x}:{x}:{x}, Sender IP: {d}.{d}.{d}.{d}, Target MAC: {x}:{x}:{x}:{x}:{x}:{x}, Target IP: {d}.{d}.{d}.{d}\n", .{
        hardware,
        protocol,
        operation,
        sender_MAC[0],
        sender_MAC[1],
        sender_MAC[2],
        sender_MAC[3],
        sender_MAC[4],
        sender_MAC[5],
        sender_ip[0],
        sender_ip[1],
        sender_ip[2],
        sender_ip[3],
        target_MAC[0],
        target_MAC[1],
        target_MAC[2],
        target_MAC[3],
        target_MAC[4],
        target_MAC[5],
        target_ip[0],
        target_ip[1],
        target_ip[2],
        target_ip[3],
    })) |string| {
        defer allocator.free(string);
        const folder = std.fs.cwd();
        if (folder.openFile("ARP.txt", .{ .mode = .read_write })) |file| {
            defer file.close();
            const end_pos = try file.getEndPos();
            _ = try file.pwrite(string, end_pos);
        } else |_| {
            return;
        }
    } else |_| {
        return;
    }
}
