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

local navio = { }
local tabuleiro = { }
local jogador = { }

local jogadorUm
local jogadorDois
local texto = { }

-- fase 1 == posicionamento, 2 == batalha, 3 == reiniciar
local fase
-- adicionar novo navio
-- local botaoNovoNavio = display.newImage( "image/not_a_very_good_image.png", display.contentWidth / 2, display.contentHeight * .9 )

local tapListener
local definirTexto
local textoAcao

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
			self.retangulos[i][j].ativo = true
			self.retangulos[i][j]:addEventListener ( "tap", tapListener )
		end

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




--------------------
-- Funções
--------------------

-- Define o estado de um novo jogo
novoJogo = function()
	jogadorUm = jogador:new( )
	jogadorDois = jogador:new( )
	jogadorDois.ia = true
	fase = 1

	definirTexto( )
	jogadorUm.pontuacao = 1000
	definirTexto()

end

-- Define o texto no topo da tela com o atual estado do jogo
-- Verifica se já existe um texto definido(se a função já foi chamada) para evitar overlap dos textos
definirTexto = function ( )
	local pontuacaoUm = jogadorUm.pontuacao
	local pontuacaoDois = jogadorDois.pontuacao

	texto.jogador = texto.jogador or display.newText( "Jogador", 50, 0)
	texto.ia = texto.ia or display.newText( "COM", largura - 50, 0 )

	if ( texto.pontuacaoUm == nil ) then
		texto.pontuacaoUm = display.newText( pontuacaoUm, 50, 30 )
		texto.pontuacaoDois = display.newText( pontuacaoDois, largura - 50, 30 )
	else
		texto.pontuacaoUm.text = pontuacaoUm
		texto.pontuacaoDois.text = pontuacaoDois
	end
	
end

-- Define a ação atual do jogador
textoAcao = function ( acao )
	if ( texto.acao == nil ) then
		texto.acao = display.newText( acao, largura / 2, 50 )
	else
		texto.acao.text = acao
	end
end

--------------------
-- Jogo
--------------------

tapListener = function( event )

	if(event.target.ativo) then
		event.target.fill = { 1, 0, 0, .5 }
		event.target.ativo = false
	else
		event.target.fill = { 0, 0, 1, .5 }
		event.target.ativo = true
	end
end

novoJogo()
definirTexto()
local t = tabuleiro:new()
t:desenharGrafico()
t:desenharRetangulos()
