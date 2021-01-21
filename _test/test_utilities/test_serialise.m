classdef test_serialise< TestCase
    properties
    end
    methods
        function this=test_serialise(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialise';
            end
            this = this@TestCase(name);

        end


        %------------------------------------------------------------------
        function test_ser_sample(this)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialise(sam1);
            sam1rec = hlp_deserialise(bytes);
            assertEqual(sam1,sam1rec);

            % - TGP 22/07/2019: commented out these two samples as the names are no longer valid
            %             sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
            %             bytes = hlp_serialise(sam2);
            %             sam2rec = hlp_deserialise(bytes);
            %             assertEqual(sam2,sam2rec);
            %
            %             sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));
            %             bytes = hlp_serialise(sam3);
            %             sam3rec = hlp_deserialise(bytes);
            %             assertEqual(sam3,sam3rec);

            sam4=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialise(sam4);
            sam4rec = hlp_deserialise(bytes);
            assertEqual(sam4,sam4rec);

        end

        %------------------------------------------------------------------
        function test_ser_instrument(this)

        % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes = hlp_serialise(inst1);
            inst1rec = hlp_deserialise(bytes);
            assertEqual(inst1,inst1rec);


            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes = hlp_serialise(inst2);
            inst2rec = hlp_deserialise(bytes);
            assertEqual(inst2,inst2rec );

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes = hlp_serialise(inst3);
            inst3rec = hlp_deserialise(bytes);
            assertEqual(inst3,inst3rec );

            %------------------------------------------------------------------
        end


        function test_ser_datamessage(this)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = DataMessage(my_struc);

            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage(123456789);

            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage('This is a test message');

            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);
        end

        function test_ser_datamessage_array(this)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end


        %% Test null
        function test_ser_array_null(this)
            test_obj = [];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end


        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(this)
            test_obj = true;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_logical_array(this)
            test_obj = [true, true, true];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(this)
            test_obj = '';
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_scalar(this)
            test_obj = 'BEEP';
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_array(this)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(this)
            test_obj = 10;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_list(this)
            test_obj = [1:10];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_array(this)
            test_obj = [1:10;1:10];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(this)
            test_obj = 3+4i;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_array(this)
            test_obj = [3+4i, 5+7i; 2+i, 1-i];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(this)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(this)
            test_struct = struct([]);
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(this)
            test_struct = struct();
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_scalar(this)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_list(this)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_array(this)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %% Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(this)
            test_sparse = sparse([],[],[]);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(this)
            test_sparse = sparse([],[],[],10,10);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(this)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(this)
            test_sparse = sparse(eye(10));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(this)
            test_sparse = sparse([],[], complex([],[]));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(this)
            test_sparse = sparse([],[],complex([],[]),10,10);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(this)
            test_sparse = sparse([1],[1], [i]);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(this)
            test_sparse = sparse([1:10],[1], i);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %% Test Function handle
        function test_ser_function_handle(this)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialise(test_func);
            test_func_rec = hlp_deserialise(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(this)
            test_cell = {};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(this)
            test_cell = {1 2 3 4};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(this)
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_complex(this)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_mixed_complex(this)
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(this)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(this)
            test_cell = {true false false true false};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_string(this)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(this)
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(this)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            test_cell = cellfun(@func2str, test_cell, 'UniformOutput',false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput',false);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_hetero(this)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            test_cell{7} = func2str(test_cell{7});
            test_cell_rec{7} = func2str(test_cell_rec{7});
            assertEqual(test_cell, test_cell_rec)
        end

    end
end