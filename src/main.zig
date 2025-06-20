const std = @import("std");
const linux = std.os.linux;
const ETH_P_ALL = 0x0003;

pub fn main() !void {

    // This is the socket. It's a syscall.
    //The domain is the kind of thing the socket catches: Could be AF_UNIX, AF_INET, AF_INET6, AF_PACKET, etc...
    //The socket type specifies the communication semantics, tcp, udp, etc. Examples: SOCK_STREAM which is TCP, SOCK_DGRAM which is UDP, SOCK_RAW which is a raw socket that needs to be manually parsed(?). Can also use | the bitwise OR operator to add SOCK_NONBLOCK so that the socket doesn't block the packages.
    // The protocol specifies what protocol to use to read with the socket. Usually only one protocol exists per socket type, so it's usually 0. But there are socket types with multiple protocols, in which case you need to specify it correctly.
    const sockfd = try std.posix.socket(linux.AF.PACKET, linux.SOCK.RAW, ETH_P_ALL);

    const if_name = "eth0";
    var ifr = std.mem.zeroes(std.os.linux.ifreq);
    std.mem.copyForwards(u8, ifr.ifrn.name[0..if_name.len], if_name);

    const if_index = ifr.ifru.ivalue;
    std.debug.print("Interface index: {}\n", .{if_index});

    //THIS IS THE LOW-LEVEL VERSION OF OPENING A FILE.
    //Yes, interacting with this is literally a file.
    //Filepath is just a string that's the filepath
    // flags is a struct containing the flags... Check the zig std library for the flags! Man pages could be different.
    //Perm should be 0, I guess.
    const fd = try std.posix.open("/dev/net/tun", .{ .ACCMODE = .RDWR }, 0);
    // This systemcall manipulates the underlying device parameters of special files. Usually terminals.
    // The fd argument must be a file descriptor (like a socket!)
    // The second argument is a device-dependent request code. The std.os.linux.SIOCGIFINDEX equals 0x8933. I have no clue why chatgibidy chose that one.
    // The third argument is an untyped pointer to memory.
    _ = std.os.linux.ioctl(sockfd, std.os.linux.SIOCGIFINDEX, @intFromPtr(&ifr));

    _ = fd;

    std.debug.print("Socket: {any}\n", .{sockfd});

    // I have no clue why chatgibidy chose sockaddr.ll . There were more. What are the differences?
    var saddr = std.mem.zeroes(std.os.linux.sockaddr.ll);
    saddr.family = std.os.linux.AF.PACKET;
    saddr.protocol = std.mem.nativeToBig(u16, ETH_P_ALL);
    saddr.ifindex = if_index;

    // Bind... binds a socket to an address. It assigns a local address to a socket. This action is described as "naming" a socket.
    // Sock is the file descriptor. The socket.
    // Addr is a pointer to a sockaddr struct. There are variants (sockaddr.ll, .in, etc)
    //len is the size in bytes of the addr struct.
    _ = try std.posix.bind(sockfd, @ptrCast(&saddr), @sizeOf(std.os.linux.sockaddr.ll));
    std.debug.print("Successfully bound the socket to the interface\n", .{});

    var buf: [4096]u8 = undefined;
    // Recv is used to receive messages from a socket. Can be used on connectionless and connection-oriented sockets. Always returns the length of the received message in bytes.
    // Sock is the socket's file descriptor.
    // buf is the buffer where the message is going to be written into.
    //Flags are the flags. Check the zig std for the flags. It suggested 0, but the man pages has more. You can check the std.os.linux.MSG for more flags, perhaps can even combined with the | OR bitwise operator.
    const n = try std.posix.recv(sockfd, &buf, 0);
    if (n > 0) {
        std.debug.print("Received {} bytes\n", .{n});
        std.debug.print("Printing the bytes: {b}\n", .{buf[0..n]});
    } else {
        std.debug.print("Could not receive a message from the socket.\n", .{});
    }
}

pub fn main4() !void {
    // You must pass ETH_P_ALL in network byte order (big-endian)
    const protocol = std.mem.nativeToBig(u16, ETH_P_ALL);

    // Syscall returns usize, we must cast and check manually
    const raw_fd = linux.syscall3(
        linux.SYS.socket,
        linux.AF.PACKET,
        linux.SOCK.RAW,
        protocol,
    );

    const end_fd: isize = @intCast(raw_fd);

    if (end_fd == -1) {
        std.debug.print("socket() failed\n", .{});
        return error.SocketFailed;
    }

    const sockfd = end_fd;
    std.debug.print("Socket opened successfully: {}\n", .{sockfd});
}
