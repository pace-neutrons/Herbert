classdef test_merge_files < TestCase
    properties
        file1='testf1.txt';
        file2='testf2.txt';
        file3='testtt.txt';
        test_dir;
    end
    methods
        %
        function this=test_merge_files(name)
            this = this@TestCase(name);
            this.test_dir = tmp_dir();
            this.file1=fullfile(this.test_dir,this.file1);
            this.file2=fullfile(this.test_dir,this.file2);
            this.file3=fullfile(this.test_dir,this.file3);

        end
        function this=setUp(this)
            id= fopen(this.file1,'w');
            for i=1:3
                fprintf(id,'%d\n',i);
            end
            fclose(id);
            id= fopen(this.file2,'w');
            for i=1:3
                fprintf(id,'%d\n',i+3);
            end
            fclose(id);

        end
        function this=tearDown(this)
            if is_file(this.file1)
                delete(this.file1);
            end
            if is_file(this.file2)
                delete(this.file2);
            end
            if is_file(this.file3)
                delete(this.file3);
            end
        end
        function this=test_missingWrong(this)
            [err,mess]=merge_files('missing_file',this.file2);
            assertTrue(err);
            assertEqual(mess,'first file to merge: missing_file do not exist')

            [err,mess]=merge_files(this.file1,'missing_file');
            assertTrue(err);
            assertEqual(mess,'second file to merge: missing_file do not exist')

        end

        function this=test_mergeInot(this)

            [err,mess]=merge_files(this.file1,this.file2,this.file3);
            assertTrue(~err);
            assertTrue(isempty(mess));

            assertTrue(is_file(this.file3));

            aa = importdata(this.file3);
            assertEqual([1;2;3;4;5;6],aa);

        end

        function this=test_mergeInPlace(this)

            [err,mess]=merge_files(this.file1,this.file2);
            assertTrue(~err);
            assertTrue(isempty(mess));

            assertTrue(is_file(this.file1));

            aa = importdata(this.file1);
            assertEqual([1;2;3;4;5;6],aa);
        end

    end

end
