package com.mygdx.game;

import com.badlogic.gdx.Application;
import com.badlogic.gdx.ApplicationAdapter;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.*;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.graphics.glutils.ShaderProgram;

public class ShaderExperimentMain extends ApplicationAdapter {
	Texture tex0, tex1, mask;
	SpriteBatch batch;
	float time = 0;
	//OrthographicCamera cam;

	OrthographicCamera cam;
	ShaderProgram shaderProgram;

	final String VERT =
			"attribute vec4 "+ShaderProgram.POSITION_ATTRIBUTE+";\n" +
					"attribute vec4 "+ShaderProgram.COLOR_ATTRIBUTE+";\n" +
					"attribute vec2 "+ShaderProgram.TEXCOORD_ATTRIBUTE+"0;\n" +

					"uniform mat4 u_projTrans;\n" +
					" \n" +
					"varying vec4 vColor;\n" +
					"varying vec2 vTexCoord;\n" +

					"void main() {\n" +
					"	vColor = "+ShaderProgram.COLOR_ATTRIBUTE+";\n" +
					"	vTexCoord = "+ShaderProgram.TEXCOORD_ATTRIBUTE+"0;\n" +
					"	gl_Position =  u_projTrans * " + ShaderProgram.POSITION_ATTRIBUTE + ";\n" +
					"}";

	final String FRAG =
			//GL ES specific stuff
			"#ifdef GL_ES\n" //
					+ "#define LOWP lowp\n" //
					+ "precision mediump float;\n" //
					+ "#else\n" //
					+ "#define LOWP \n" //
					+ "#endif\n" + //
					"varying LOWP vec4 vColor;\n" +
					"varying vec2 vTexCoord;\n" +
					"uniform sampler2D u_texture;\n" +
					"void main() {\n" +
					"	vec4 texColor = texture2D(u_texture, vTexCoord);\n" +
					"	\n" +
					"	texColor.rgb = 1.0 - texColor.rgb;\n" +
					"	\n" +
					"	gl_FragColor = texColor * vColor;\n" +
					"}";
	
	@Override
	public void create () {
		batch = new SpriteBatch();
		Gdx.app.setLogLevel(Application.LOG_DEBUG);
		/*img = new Texture("badlogic.jpg");
		Pixmap pixmap  = new Pixmap(256,256, Pixmap.Format.RGBA8888);
		for (int x = 0; x < pixmap.getWidth(); x++) {
			for (int y = 0; y < pixmap.getHeight(); y++) {
				pixmap.setColor(0.2f,.04f,0.75f,1);
				pixmap.drawPixel(x,y);
			}
		}

		tex = new Texture(pixmap);
		pixmap.dispose();*/

		tex0 = new Texture(Gdx.files.internal("shader_assets/grass.png"));
		tex1 = new Texture(Gdx.files.internal("shader_assets/light_blue.png"));
		mask = new Texture(Gdx.files.internal("shader_assets/mask.png"));

		ShaderProgram.pedantic = false;
		shaderProgram = new ShaderProgram(Gdx.files.internal("shaders/shader1.vsh.glsl"), Gdx.files.internal("shaders/shader1.fsh.glsl"));
		//shaderProgram = new ShaderProgram(VERT, FRAG);
		Gdx.app.log("Shader", shaderProgram.isCompiled() ? "COMPILED" : shaderProgram.getLog());

		shaderProgram.begin();
		shaderProgram.setUniformi("u_texture1", 1);
		shaderProgram.setUniformi("u_mask", 2);
		shaderProgram.end();

		mask.bind(2);
		tex1.bind(1);

		Gdx.gl.glActiveTexture(GL20.GL_TEXTURE0);

		//batch = new SpriteBatch(1000, shaderProgram);
		batch.setShader(shaderProgram);
		cam = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
		cam.setToOrtho(false);
	}

	@Override
	public void render () {
		Gdx.gl.glClearColor(0, 1, 0, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.begin();
		shaderProgram.setUniformf("time", time+=Gdx.graphics.getDeltaTime());
		batch.draw(tex0, 0, 0);
		batch.draw(tex0, 256, 0);
		batch.draw(tex0, 0, 256);
		batch.draw(tex0, 256, 256);
		batch.end();
	}
	
	@Override
	public void dispose () {
		batch.dispose();
		//img.dispose();
	}

	@Override
	public void resize(int width, int height) {
		cam.setToOrtho(false, width, height);
		batch.setProjectionMatrix(cam.combined);
		shaderProgram.begin();
		shaderProgram.setUniformf("u_resolution", width, height);
		shaderProgram.end();
	}
}
