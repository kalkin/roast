use v6;

use Test;

plan 97;

#L<S02/Mutable types/Array>

# array of strings

my @array1 = ("foo", "bar", "baz");
isa_ok(@array1, Array);

is(+@array1, 3, 'the array1 has 3 elements');
is(@array1[0], 'foo', 'got the right value at array1 index 0');
is(@array1[1], 'bar', 'got the right value at array1 index 1');
is(@array1[2], 'baz', 'got the right value at array1 index 2');


is(@array1.[0], 'foo', 'got the right value at array1 index 0 using the . notation');


# array with strings, numbers and undef
my @array2 = ("test", 1, undef);
{
    isa_ok(@array2, Array);

    is(+@array2, 3, 'the array2 has 3 elements');
    is(@array2[0], 'test', 'got the right value at array2 index 0');
    is(@array2[1], 1,      'got the right value at array2 index 1');
    ok(!@array2[2].defined,  'got the right value at array2 index 2');
}

# combine 2 arrays
{
    my @array3 = (@array1, @array2);
    isa_ok(@array3, Array);

    is(+@array3, 6, 'the array3 has 6 elements'); 
    is(@array3[0], 'foo', 'got the right value at array3 index 0'); 
    is(@array3[1], 'bar', 'got the right value at array3 index 1'); 
    is(@array3[2], 'baz', 'got the right value at array3 index 2'); 
    is(@array3[3], 'test', 'got the right value at array3 index 3'); 
    is(@array3[4], 1,      'got the right value at array3 index 4'); 
    ok(!@array3[5].defined,'got the right value at array3 index 5');
}

{
    # array slice
    my @array4 = @array2[2, 1, 0];
    isa_ok(@array4, Array);

    is(+@array4, 3, 'the array4 has 3 elements');
    ok(!defined(@array4[0]), 'got the right value at array4 index 0');
    is(@array4[1], 1,      'got the right value at array4 index 1');
    is(@array4[2], 'test', 'got the right value at array4 index 2');
}

{
    # create new array with 2 array slices
    my @array5 = ( @array2[2, 1, 0], @array1[2, 1, 0] );
    isa_ok(@array5, Array);

    is(+@array5, 6, 'the array5 has 6 elements');
    ok(!defined(@array5[0]),  'got the right value at array5 index 0');
    is(@array5[1], 1,      'got the right value at array5 index 1');
    is(@array5[2], 'test', 'got the right value at array5 index 2');
    is(@array5[3], 'baz',  'got the right value at array5 index 3');
    is(@array5[4], 'bar',  'got the right value at array5 index 4');
    is(@array5[5], 'foo',  'got the right value at array5 index 5');
}

{
    # create an array slice with an array (in a variable)

    my @slice = (2, 0, 1);
    my @array6 = @array1[@slice];
    isa_ok(@array6, Array);

    is(+@array6, 3, 'the array6 has 3 elements'); 
    is(@array6[0], 'baz', 'got the right value at array6 index 0'); 
    is(@array6[1], 'foo', 'got the right value at array6 index 1'); 
    is(@array6[2], 'bar', 'got the right value at array6 index 2'); 
}

{
    # create an array slice with an array constructed with ()
    my @array7 = @array1[(2, 1, 0)];
    isa_ok(@array7, Array);

    is(+@array7, 3, 'the array7 has 3 elements');
    is(@array7[0], 'baz', 'got the right value at array7 index 0');
    is(@array7[1], 'bar', 'got the right value at array7 index 1');
    is(@array7[2], 'foo', 'got the right value at array7 index 2');
}

{
    # odd slices
    my $result1 = (1, 2, 3, 4)[1];
    is($result1, 2, 'got the right value from the slice');

    my $result2 = [1, 2, 3, 4][2];
    is($result2, 3, 'got the right value from the slice');
}

# swap two elements test moved to t/op/assign.t

# empty arrays
{
    my @array9;
    isa_ok(@array9, Array);
    is(+@array9, 0, "new arrays are empty");

    my @array10 = (1, 2, 3,);
    is(+@array10, 3, "trailing commas make correct array"); 
}

#?pugs skip "multi-dim arrays not implemented"
#?rakudo skip "multi-dim arrays"
{
# declare a multidimension array
    eval_lives_ok('my @multidim[0..3; 0..1]', "multidimension array");
    my @array11 is shape(2,4);

    # XXX what should that test actually do?
    ok(eval('@array11[2,0] = 12'), "push the value to a multidimension array");
}

#?rakudo skip "rest not properly fudged yet"
{
    # declare the array with data type
    my Int @array;
    lives_ok { @array[0] = 23 },                   "stuffing Ints in an Int array works";
    dies_ok  { @array[1] = $*ERR }, "stuffing IO in an Int array does not work";
}

#?rakudo skip "no whatever star yet"
#?pugs skip "no whatever star yet"
{
    my @array12 = ('a', 'b', 'c', 'e'); 

    # indexing from the end
    is @array12[*-1],'e', "indexing from the end [*-1]";

    # end index range
    is ~@array12[*-4 .. *-2], 'a b c', "end indices [*-4 .. *-2]";

    # end index as lvalue
    @array12[*-1]   = 'd';
    is @array12[*-1], 'd', "assigns to the correct end slice index"; 
    is ~@array12,'a b c d', "assignment to end index correctly alters the array";
}

#?rakudo skip "no whatever star yet"
#?pugs skip "no whatever star yet"
{
    my @array13 = ('a', 'b', 'c', 'd'); 
    # end index range as lvalue
    @array13[*-4 .. *-1]   = ('d', 'c', 'b', 'a'); # ('a'..'d').reverse
    is ~@array13, 'd c b a', "end range as lvalue"; 

    #hat trick
    my @array14 = ('a', 'b', 'c', 'd');
    my @b = 0..3;
    ((@b[*-3,*-2,*-1,*-4] = @array14)= @array14[*-1,*-2,*-3,*-4]);

    is ~@b, 
        'a d c b', 
        "hat trick:
        assign to a end-indexed slice array from array  
        lvalue in assignment is then lvalue to end-indexed slice as rvalue"; 
}

# This test may seem overly simplistic, but it was actually a bug in PIL2JS, so
# why not write a test for it so other backends can benefit of it, too? :)
{
  my @arr = (0, 1, 2, 3);
  @arr[0] = "new value";
  is @arr[0], "new value", "modifying of array contents (constants) works";
}

#?rakudo skip "no whatever star yet"
#?pugs skip "no whatever star yet"
{
  my @arr;
  lives_ok { @arr[*-1] },  "readonly accessing [*-1] of an empty array is ok (1)";
  ok !(try { @arr[*-1] }), "readonly accessing [*-1] of an empty array is ok (2)";
  dies_ok { @arr[*-1] = 42 },      "assigning to [*-1] of an empty array is fatal";
  dies_ok { @arr[*-1] := 42 },     "binding [*-1] of an empty array is fatal";
}

#?rakudo skip "no whatever star yet"
#?pugs skip "no whatever star yet"
{
  my @arr = (23);
  lives_ok { @arr[*-2] },  "readonly accessing [*-2] of an one-elem array is ok (1)";
  ok !(try { @arr[*-2] }), "readonly accessing [*-2] of an one-elem array is ok (2)";
  dies_ok { @arr[*-2] = 42 },      "assigning to [*-2] of an one-elem array is fatal";
  dies_ok { @arr[*-2] := 42 },     "binding [*-2] of an empty array is fatal";
}

{
  my @arr = <a normal array with nothing funny>;
  my $minus_one = -1;

  # XXX should that even parse? 
  #?rakudo todo '@arr[-1] should fail'
  dies_ok { @arr[-1] }, "readonly accessing [-1] of normal array is fatal";
  lives_ok { @arr[ $minus_one ] }, "indirectly accessing [-1] " ~
                                   "through a variable is ok";
  #?rakudo 2 skip '@arr[-1] should fail'
  dies_ok { @arr[-1] = 42 }, "assigning to [-1] of a normal array is fatal";
  dies_ok { @arr[-1] := 42 }, "binding [-1] of a normal array is fatal";
}

# L<S09/Fixed-size arrays>

#?rakudo skip 'my @arr[*] parsefail'
{
    my @arr[*];
    @arr[42] = "foo";
    ok(+@arr, 42, 'my @arr[*] autoextends like my @arr');
}

#?rakudo skip 'my @arr[num] parsefail'
{
    my @arr[7] = <a b c d e f g>;
    is(@arr, <a b c d e f g>, 'my @arr[num] can hold num things');
    dies_ok({push @arr, 'h'}, 'adding past num items in my @arr[num] dies');
    dies_ok({@arr[7]}, 'accessing past num items in my @arr[num] dies');
}

#?rakudo skip 'my @arr[num] parsefail'
{
    lives_ok({ my @arr\    [7]}, 'array with fixed size with unspace');
    eval_dies_ok('my @arr.[8]', 'array with dot form dies');
    eval_dies_ok('my @arr\    .[8]', 'array with dot form and unspace dies');
}

# L<S09/Typed arrays>

#?rakudo skip 'my @arr of Type parsefail'
{
    my @arr of Int = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my @arr of Type works');
    dies_ok({push @arr, 's'}, 'type constraints on my @arr of Type works (1)');
    dies_ok({push @arr, 4.2}, 'type constraints on my @arr of Type works (2)');
}

#?rakudo skip 'my @arr[num] of Type parsefail'
{
    my @arr[5] of Int = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my @arr[num] of Type works');

    dies_ok({push @arr, 123}, 'boundary constraints on my @arr[num] of Type works');
    pop @arr; # remove the last item to ensure the next ones are type constraints
    dies_ok({push @arr, 's'}, 'type constraints on my @arr[num] of Type works (1)');
    dies_ok({push @arr, 4.2}, 'type constraints on my @arr[num] of Type works (2)');
}

#?rakudo skip 'my @arr(-->Type) parsefail'
{
    my @arr(-->Num) = <1 2.1 3.2>;
    is(@arr, <1 2.1 3.2>, 'my @arr[-->Type] works');

    lives_ok({push @arr, 4.3}, 'adding the proper type works');
    dies_ok({push @arr, 'string'}, 'type constraints on my @arr[-->Type] works');
}

#?rakudo skip 'my @arr[num-->Type] parsefail'
{
    my @arr[3](-->Num) = <1 2.1 3.2>;
    is(@arr, <1 2.1 3.2>, 'my @arr[num-->Type] works');

    dies_ok({push @arr, 4.3}, 'boundary constraints work on my @arr[num-->Type]');
    pop @arr; # remove the last item to ensure the next ones are type constraints
    dies_ok({push @arr, 'string'}, 'type constraints on my @arr[-->Type] works');
}

#?rakudo skip 'my Type @arr parsefail'
{
    my int @arr = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my Type @arr works');
    dies_ok({push @arr, 's'}, 'type constraints on my Type @arr works (1)');
    dies_ok({push @arr, 4.2}, 'type constraints on my Type @arr works (2)');
}

#?rakudo skip 'my Type @arr[num] parsefail'
{
    my int @arr[5] = <1 2 3 4 5>;
    is(@arr, <1 2 3 4 5>, 'my Type @arr[num] works');

    dies_ok({push @arr, 123}, 'boundary constraints on my Type @arr[num] works');
    pop @arr; # remove the last item to ensure the next ones are type constraints
    dies_ok({push @arr, 's'}, 'type constraints on my Type @arr[num] works (1)');
    dies_ok({push @arr, 4.2}, 'type constraints on my Type @arr[num]  works (2)');
}
