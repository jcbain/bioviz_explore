let genome;
let template;

d3.json('data/genome_individual.json').then(function(data){
    genome = data;
});

d3.json('data/genome_template.json').then(function(data){
    template = data;
});


Promise.all([
    d3.json('data/genome_individual.json'),
    d3.json('data/genome_template.json'),
]).then(function(files){
    let genomeg = files[0];
    let genomet = files[1];
    console.log(genomeg);
})