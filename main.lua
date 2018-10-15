-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

math.randomseed( os.time())


-------------------
-- Variáveis
-------------------

-- altura e largura do tabuleiro
local altura = display.contentHeight * .6
local largura = display.contentWidth
local navioCor = { .6, .4, .4 }
local tiroCertoCor = { 0, .3, .1 }
local tiroErradoCor = { .5, .1, .1 }

local navio = { }
local tabuleiro = { }
local jogador = { }

local jogadorUm
local ia
local texto = { }
local tamanhoNavio
local posicaoNavio = { }


-- fase 1 == posicionamento, 2 == batalha, 3 == reiniciar
local fase
-- adicionar novo navio
-- local botaoNovoNavio = display.newImage( "image/not_a_very_good_image.png", display.contentWidth / 2, display.contentHeight * .9 )

local posicionarNavioListener
local orientacaoNavioListener
local tapListener
local definirTexto
local textoTopo
local posicionarEvento
local orientacaoEvento
local mudarCor

------------------- 
-- Objetos
-------------------

-- Classe navio
-- dano = 0, posicao = {}, tamanho = 0
-- construtor para a criação de um novo objeto
function navio:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.dano = 0
	obj.posicao = {}
	obj.tamanho = 0
	return obj
end



-- Classe tabuleiro
-- navios = {}, graficoLinha = {}, graficoColuna = {}, retangulos = {}
-- construtor
function tabuleiro:new ()
      obj = {}
      setmetatable(obj, self)
      self.__index = self
      obj.navios = {}
      obj.graficoLinha = {}
      obj.graficoColuna = {}
      obj.retangulos = {}
      return obj
end

-- Classe jogador
-- pontuacao = 0, tabuleiro = tabuleiro:new(), ia = false
-- construtor
function jogador:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.pontuacao = 0
	obj.tabuleiro = tabuleiro:new()
	obj.ia = false
	return obj
end



--------------------
-- Métodos
--------------------

-- desenha na tela o tabuleiro
function tabuleiro:desenharGrafico( )
	
	for i = 1, 9 do
		self.graficoLinha[i] = display.newLine( 0, altura * i *.10 + 100, 
		largura, altura * i * .10 + 100 ) 

		self.graficoColuna[i] = display.newLine( largura * i * .10, 100, 
		 largura * i * .10, altura + 100) 
	end

end

-- desenha retângulos na tela para serem usados pelos listeners
function tabuleiro:desenharRetangulos( )
	local paint = { 0, .15, .60}

	for i=1,10 do
		
		self.retangulos[i] = {}
		for j=1, 10 do
			self.retangulos[i][j] = display.newRect( ( largura / 20 * ( i + i - 1) ) , (  altura / 20 * ( j + j - 1) + 100) , 
				largura / 10, altura / 10 )
			self.retangulos[i][j].fill = paint
			self.retangulos[i][j].alpha = .5
			self.retangulos[i][j].linha = i
			self.retangulos[i][j].coluna = j
			self.retangulos[i][j].ocupado = false
			-- teste remover depois
			self.retangulos[i][j]:addEventListener ( "tap", tapListener )
		end

	end

end

-- verifica se já existe um navio ocupando aquele espaço
-- recebe como parâmetros dois valores com as posições a serem checadas
-- retorna true se já estiver ocupado, senão retorna false
function tabuleiro:celulaOcupada( linha, coluna )	
	return self.retangulos[linha][coluna].ocupado
end


-- Posiciona um novo navio no tabuleiro
function jogador:posicionarNavio( pos, tam ) 
	local novoNavio = navio:new()
	novoNavio.posicao = pos
	novoNavio.tamanho = tam

	table.insert( self.tabuleiro.navios, novoNavio )

	-- percorre o grafico no eixo x muda a cor e remove o listener
	for i = novoNavio.posicao[1], novoNavio.posicao[2] do
		local retangulo = self.tabuleiro.retangulos[novoNavio.posicao[3]][i]
		mudarCor ( retangulo, navioCor ) 
		retangulo.ocupado = true
		retangulo:removeEventListener( "tap", posicionarNavioListener )
	end

	-- percorre o grafico no eixo y muda a cor e remove o listener
	for i = novoNavio.posicao[3], novoNavio.posicao[4] do
		local retangulo =  self.tabuleiro.retangulos[i][novoNavio.posicao[1]]
		mudarCor ( retangulo, navioCor )
		retangulo.ocupado = true
		retangulo:removeEventListener( "tap", posicionarNavioListener )
	end
	
end

-- atira na célula selecionada
function jogador:atirar( jogador2, linha, coluna)
	local acertou = false
	local pontuacao = self.pontuacao

	for i = 1, #jogador2.tabuleiro.navios do
		-- checa se o valor x e y estão entre as posições x1, x2 e y1, y2, respectivamente 

		if ( (linha >= jogador2.tabuleiro.navios[i].posicao[1] and linha <= jogador2.tabuleiro.navios[i].posicao[2])
			and 
			 (coluna >= jogador2.tabuleiro.navios[i].posicao[3] and coluna <= jogador2.tabuleiro.navios[i].posicao[4]) ) then
			acertou = true
			jogador2.tabuleiro.navios[i].dano = jogador2.tabuleiro.navios[i].dano + 1
			
			if ( jogador2.tabuleiro.navios[i].dano == jogador2.tabuleiro.navios[i].tamanho ) then
				pontuacao = pontuacao + jogador2.tabuleiro.navios[i].tamanho * 10
			end
		end
		
	end

	self.pontuacao = pontuacao

	return acertou

end



--------------------
-- Event Listeners
--------------------

posicionarNavioListener = function ( event )
	posicaoNavio.l1 = event.target.linha
	posicaoNavio.c1 = event.target.coluna

	if ( tamanhoNavio == 1 ) then
		posicaoNavio.l2 = event.target.linha
		posicaoNavio.c2 = event.target.coluna
		jogadorUm:posicionarNavio( posicaoNavio, tamanhoNavio )
		textoFundo( "Navio posicionado" )
		tamanhoNavio = tamanhoNavio + 1
	else	
		removerEventos()
		if ( orientacaoEvento() ) then
			textoFundo( "Navio não pode ser posicionado aqui" )
			posicionarEvento()
		end
		
	end
end

orientacaoNavioListener = function ( event )
	textoFundo( "Defina a orientação")
	posicaoNavio.l2 = event.target.linha
	posicaoNavio.c2 = event.target.coluna
	jogadorUm:posicionarNavio( posicaoNavio, tamanhoNavio )
	textoFundo( "Navio posicionado" )
	tamanhoNavio = tamanhoNavio + 1
end


--------------------
-- Funções
--------------------

-- Define o estado de um novo jogo
novoJogo = function()
	jogadorUm = jogador:new( )
	ia = jogador:new( )
	ia.ia = true
	tamanhoNavio = 1
	posicaoNavio.l1 = 0
	posicaoNavio.l2 = 0
	posicaoNavio.c1 = 0
	posicaoNavio.c2 = 0

	definirTexto()

end



-- Adiciona os listeners para o posicionamento dos navios
posicionarEvento = function ( )	
	for i=1, 10 do
		for j=1, 10 do
			if ( jogadorUm.tabuleiro.retangulos[i][j].ocupado == false ) then
				jogadorUm.tabuleiro.retangulos[i][j]:addEventListener( "tap", posicionarNavioListener )
			end
		end
	end
end

-- Remove todos os event listeners do tabuleiro
removerEventos = function ( )
	for i=1, 10 do
		for j=1, 10 do
			jogadorUm.tabuleiro.retangulos[i][j]:removeEventListener( "tap", posicionarNavioListener )
		end
	end
end

-- Modifica os listeners dos retângulos para aceitar apenas posições válidas
-- Retorna true se nenhum navio puder ser posicionado
orientacaoEvento = function ( )
	local valido = true
	local voltar = true
	local linhaNeg = posicaoNavio.l1 - tamanhoNavio
	local linhaPos = posicaoNavio.l1 + tamanhoNavio
	local colunaNeg = posicaoNavio.c1 - tamanhoNavio
	local colunaPos = posicaoNavio.c1 + tamanhoNavio

	if ( linhaNeg > 0 ) then
		for i = posicaoNavio.l1, linhaNeg, -1 do
			if ( jogadorUm.tabuleiro:celulaOcupada( i, posicaoNavio.c1 ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[linhaNeg][posicaoNavio.c1]:addEventListener( "tap", orientacaoNavioListener )
			voltar = false
		end
	end

-----------------------------------------------------------------------------------------

	if ( linhaPos < 11 ) then
		valido = true
		for i = posicaoNavio.l1, linhaPos do
			if ( jogadorUm.tabuleiro:celulaOcupada( i, posicaoNavio.c1 ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[linhaPos][posicaoNavio.c1]:addEventListener( "tap", orientacaoNavioListener )
			voltar = false
		end
	end

-----------------------------------------------------------------------------------------

	if ( colunaNeg > 0 ) then
		valido = true
		for i = posicaoNavio.c1, colunaNeg, -1 do
			if ( jogadorUm.tabuleiro:celulaOcupada( posicaoNavio.l1, i ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[posicaoNavio.l1][colunaNeg]:addEventListener( "tap", orientacaoNavioListener )
			voltar = false
		end
	end


-----------------------------------------------------------------------------------------

	if ( colunaPos < 11 ) then
		valido = true
		for i = posicaoNavio.c1, colunaPos do
			if ( jogadorUm.tabuleiro:celulaOcupada( posicaoNavio.l1, i ) ) then
				valido = false
				break
			end
		end

		if ( valido ) then
			jogadorUm.tabuleiro.retangulos[posicaoNavio.l1][colunaNeg]:addEventListener( "tap", orientacaoNavioListener )
			voltar = false
		end
	end

	return voltar
end

-- Define o texto no topo da tela com o atual estado do jogo
-- Verifica se já existe um texto definido(se a função já foi chamada) para evitar overlap dos textos
definirTexto = function ( )
	local pontuacaoUm = jogadorUm.pontuacao
	local pontuacaoIa = ia.pontuacao

	texto.jogador = texto.jogador or display.newText( "Jogador", 50, 0)
	texto.ia = texto.ia or display.newText( "COM", largura - 50, 0 )

	if ( texto.pontuacaoUm == nil ) then
		texto.pontuacaoUm = display.newText( pontuacaoUm, 50, 30 )
		texto.pontuacaoIa = display.newText( pontuacaoIa, largura - 50, 30 )
	else
		texto.pontuacaoUm.text = pontuacaoUm
		texto.pontuacaoIa.text = pontuacaoIa
	end
	
end

-- Define o texto no topo da tela
textoTopo = function ( str )
	if ( texto.topo == nil ) then
		texto.topo = display.newText( str, largura / 2, 50 )
		texto.topo.size = 15
	else
		texto.topo.text = str
	end
end

-- Define o texto no fundo da tela
textoFundo = function ( str )
	if ( texto.fundo == nil ) then
		texto.fundo = display.newText( str, largura / 2, display.contentHeight - 50 )
		texto.fundo.size = 15
	else
		texto.fundo.text = str
	end
end

-- Muda a cor de um retâgulo
-- Recebe um retâgulo e a cor
mudarCor = function ( retangulo, cor )
	retangulo.fill = cor
end


--------------------
-- Jogo
--------------------

tapListener = function( event )

	if(event.target.ativo) then
		event.target.fill = navioCor
		event.target.ativo = false

	else
		event.target.fill = tiroErradoCor
		event.target.ativo = true
	end

end

novoJogo()
definirTexto()
local t = tabuleiro:new()
t:desenharGrafico()
t:desenharRetangulos()
textoFundo('teste')