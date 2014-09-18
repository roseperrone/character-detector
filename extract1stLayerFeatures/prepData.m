function [X, y] = prepData(e, quad, whetherASCII, M, P)
	baseSz = 8;
    m = length(e.class);
	szImg = 12;
    nTiles = (szImg-baseSz+1)^2; %sliding tiles

    K = 62;
	y = zeros( m,1 );
	X = zeros( nTiles * m, baseSz ^ 2 );
    for i=1:m
        if quad==1
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(1:12,1:12,i),[baseSz baseSz],'sliding')';
        end
        if quad==2
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(1:12,6:17,i),[baseSz baseSz],'sliding')';
        end
        if quad==3
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(1:12,11:22,i),[baseSz baseSz],'sliding')';
        end
        if quad==4
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(1:12,16:27,i),[baseSz baseSz],'sliding')';
        end
        if quad==5
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(1:12,21:32,i),[baseSz baseSz],'sliding')';
        end
        if quad==6
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(6:17,1:12,i),[baseSz baseSz],'sliding')';
        end
        if quad==7
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(6:17,6:17,i),[baseSz baseSz],'sliding')';
        end
        if quad==8
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(6:17,11:22,i),[baseSz baseSz],'sliding')';
        end
        if quad==9
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(6:17,16:27,i),[baseSz baseSz],'sliding')';
        end
        if quad==10
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(6:17,21:32,i),[baseSz baseSz],'sliding')';
        end
        if quad==11
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(11:22,1:12,i),[baseSz baseSz],'sliding')';
        end
        if quad==12
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(11:22,6:17,i),[baseSz baseSz],'sliding')';
        end
        if quad==13
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(11:22,11:22,i),[baseSz baseSz],'sliding')';
        end
        if quad==14
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(11:22,16:27,i),[baseSz baseSz],'sliding')';
        end
        if quad==15
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(11:22,21:32,i),[baseSz baseSz],'sliding')';
        end
        if quad==16
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(16:27,1:12,i),[baseSz baseSz],'sliding')';
        end
        if quad==17
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(16:27,6:17,i),[baseSz baseSz],'sliding')';
        end
        if quad==18
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(16:27,11:22,i),[baseSz baseSz],'sliding')';
        end
        if quad==19
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(16:27,16:27,i),[baseSz baseSz],'sliding')';
        end
        if quad==20
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(16:27,21:32,i),[baseSz baseSz],'sliding')';
        end
        if quad==21
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(21:32,1:12,i),[baseSz baseSz],'sliding')';
        end
        if quad==22
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(21:32,6:17,i),[baseSz baseSz],'sliding')';
        end
        if quad==23
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(21:32,11:22,i),[baseSz baseSz],'sliding')';
        end
        if quad==24
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(21:32,16:27,i),[baseSz baseSz],'sliding')';
        end
        if quad==25
            X((i-1)*nTiles+1 : i*nTiles,:) = im2col(e.img(21:32,21:32,i),[baseSz baseSz],'sliding')';
        end
        %Xy(i,:) = reshape( e.img(:,:,i), [ 1  32*32 ]);
        if(whetherASCII)
            if(e.class(i)>=97) %lowercase 27-52
                y(i) = e.class(i)-70;
            end
            if(e.class(i)>=65 && e.class(i)<=90)%upper case 1-26
                y(i) = e.class(i)-64;
            end
            if(e.class(i)>=48 && e.class(i)<=57)%numbers 53-62
                y(i) = e.class(i)+5;
            end
        else
            y(i) = e.class(i);
        end
    end
	[X, ~,~] = normalizeAndZCA(X,M,P);
end