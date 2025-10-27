function moveServo(n_servo, x, port)
% x can range from 0 to 1
x = round(x*8000+2000);
command1 = [0x84, n_servo, binvec2dec(bitget(x,1:7)), binvec2dec(bitget(x,8:14))];
write(port, command1, "char");
end