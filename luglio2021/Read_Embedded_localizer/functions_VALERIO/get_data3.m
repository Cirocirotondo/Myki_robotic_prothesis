function [loc, t_loc, t_iter, t_abs, nMag] = get_data3(s, nMag)
  %get_data3 acquisisce le localizzazioni dall'embedded e i tempi impiegati

  n = 0;
  while(n<30+24*nMag)
    n = s.NumBytesAvailable;
  end

  data = read(s, s.NumBytesAvailable, "uint8");
  i = find(char(data) == 'L');
  i = i(1);
  if ((char(data(i+1)) == 'O') && (char(data(i+2)) == 'C'))
    if (nMag ~= uint8(data(i+5)))
      warning("Expected magnets: %i; actual magnets: %i", nMag, uint8(data(6)));
      nMag = uint8(data(i+5));
    end
    if ((char(data(i+26+24*nMag)) == 'E') && (char(data(i+27+24*nMag)) == 'N') && (char(data(i+28+24*nMag)) == 'D'))
      for m = 1:nMag
        for n = 1:6
          A = uint8(data(i+7+((n-1)*4+(m-1)*24):i+10+((n-1)*4+(m-1)*24)));
          loc(m, n) = typecast(A, 'single');
        end
      end
      if (char(data(i+12+(20+(nMag-1)*24))) == 'T')
        A = uint8(data(i+13+(20+(nMag-1)*24):i+16+(20+(nMag-1)*24)));
        t_loc = typecast(A, 'single');
        A = uint8(data(i+4+13+(20+(nMag-1)*24):i+4+16+(20+(nMag-1)*24)));
        t_iter = typecast(A, 'single');
        A = uint8(data(i+8+13+(20+(nMag-1)*24):i+8+16+(20+(nMag-1)*24)));
        t_abs = typecast(A, 'single');
      end
    end
  end
end
