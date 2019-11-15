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

    genomet.forEach(function(position){
        var result = genomeg.filter(function(g){
            return g.position === position.position;
        });
        position.select_coef = (result[0] !== undefined) ? result[0].select_coef : 0;
    })
    console.log(genomet);
    
    const uniqueGenomes = (value, index, self) => {
        return self.indexOf(value) === index;
    }
    
    Array.prototype.unique = function() {
        return this.filter(function (value, index, self){
            return self.indexOf(value) === index;
        });
    }
    
    const sampleArray = [];
    genomeg.forEach(function(d){ sampleArray.push(d.genome); });
    console.log(sampleArray.unique());
    
    // sampleArray.unique().forEach(function(d){
    //     var newResult = genomeg.filter(function(g){
    //         return g.genome === d;
    //     });
    //     genomet.forEach(function(position){
    //         var newNewResult = newResult.filter(function(n){
    //             return n.position === position.position;
    //         });
    //         position.select_coef = (newNewResult[0] !== undefined) ? newNewResult[0].select_coef : 0;
    //     })
    // })
    // console.log(genomet);
    
    let newTemplate = []
    sampleArray.unique().forEach(function(d){
        newTemplate = [...genomet]
        var newResult = genomeg.filter(function(g){
            return g.genome === d;
        });
        newTemplate.forEach(function(position){
            var newNewResult = newResult.filter(function(n){
                return n.position === position.position;
            });
            position.select_coef = (newNewResult[0] !== undefined) ? newNewResult[0].select_coef : 0;
        });
        console.log(newTemplate);
    })
    


    console.log(genomeg.filter(function(d){return d.genome === "genome1";}))
})

